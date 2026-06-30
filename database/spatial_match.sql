-- =============================================================
-- Spatial Match Migration — PostGIS Provider Proximity Search
-- =============================================================
-- Run this in the Supabase SQL Editor AFTER dispatch_schema.sql
-- (which already enables PostGIS, adds the location column
--  and GIST index on profiles, and defines match_best_provider).
--
-- This migration adds:
--   1. latitude / longitude columns on profiles (if absent)
--   2. Trigger to auto-sync location FROM (latitude, longitude)
--   3. Backfill of location for existing profiles
--   4. match_providers_by_radius() using ST_DWithin
-- =============================================================

CREATE EXTENSION IF NOT EXISTS postgis SCHEMA extensions;

-- add scalar lat/lng columns if they do not exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'latitude'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN latitude DOUBLE PRECISION;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'longitude'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN longitude DOUBLE PRECISION;
  END IF;
END $$;

-- add geography column if absent
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'location'
  ) THEN
    ALTER TABLE public.profiles
      ADD COLUMN location extensions.geography(Point, 4326);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_provider_location
  ON public.profiles USING GIST (location);

-- trigger function to keep location in sync
CREATE OR REPLACE FUNCTION public.update_profile_location()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(
      ST_MakePoint(NEW.longitude, NEW.latitude),
      4326
    )::extensions.geography;
  ELSE
    NEW.location := NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_location ON public.profiles;

CREATE TRIGGER trg_profiles_location
  BEFORE INSERT OR UPDATE OF latitude, longitude
  ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_profile_location();

-- backfill existing rows
UPDATE public.profiles
SET location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::extensions.geography
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND location IS NULL;

-- match_providers_by_radius()
CREATE OR REPLACE FUNCTION public.match_providers_by_radius(
  p_lat           DOUBLE PRECISION,
  p_lng           DOUBLE PRECISION,
  p_radius_meters DOUBLE PRECISION DEFAULT 4000,
  p_service_type  TEXT DEFAULT NULL
)
RETURNS TABLE(
  provider_id      UUID,
  distance_meters  DOUBLE PRECISION,
  latitude         DOUBLE PRECISION,
  longitude        DOUBLE PRECISION,
  display_name     TEXT,
  skill_profession TEXT,
  is_verified      BOOLEAN
)
LANGUAGE plpgsql STABLE
SET search_path = public, extensions
AS $$
DECLARE
  v_client_location extensions.geography;
BEGIN
  v_client_location := ST_SetSRID(
    ST_MakePoint(p_lng, p_lat),
    4326
  )::extensions.geography;

  RETURN QUERY
  SELECT
    p.id,
    ST_Distance(p.location, v_client_location) AS distance_meters,
    p.latitude,
    p.longitude,
    p.display_name,
    p.skill_profession,
    p.is_verified
  FROM public.profiles p
  WHERE p.location IS NOT NULL
    AND ST_DWithin(p.location, v_client_location, p_radius_meters)
    AND (p_service_type IS NULL OR p.service_category = p_service_type)
  ORDER BY distance_meters ASC;
END;
$$;

COMMENT ON FUNCTION public.match_providers_by_radius IS
  'Returns providers within p_radius_meters of a client location, ordered by proximity.';
