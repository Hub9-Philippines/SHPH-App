-- =============================================================
-- Server-Authoritative Dispatch Engine — Database Schema
-- =============================================================
-- Run this in the Supabase SQL Editor.
-- All statements are idempotent (safe to run repeatedly).
-- =============================================================

-- 0. Ensure PostGIS is available
CREATE EXTENSION IF NOT EXISTS postgis SCHEMA extensions;

-- =============================================================
-- PROFILES — add dispatch columns
-- =============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS location extensions.geography(Point, 4326),
  ADD COLUMN IF NOT EXISTS is_available BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS service_category TEXT;

CREATE INDEX IF NOT EXISTS idx_provider_location
  ON public.profiles USING GIST (location);

CREATE INDEX IF NOT EXISTS idx_provider_availability
  ON public.profiles (is_available, service_category)
  WHERE is_available = true;

-- =============================================================
-- ENUM — dispatch_status
-- =============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dispatch_status') THEN
    CREATE TYPE dispatch_status AS ENUM (
      'searching', 'offered', 'assigned', 'completed', 'timed_out', 'cancelled'
    );
  END IF;
END $$;

-- =============================================================
-- JOB REQUESTS table
-- =============================================================
CREATE TABLE IF NOT EXISTS public.job_requests (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  service_type    TEXT NOT NULL,
  location_lat    DOUBLE PRECISION NOT NULL,
  location_lng    DOUBLE PRECISION NOT NULL,
  requested_time  TIMESTAMPTZ NOT NULL,
  status          dispatch_status DEFAULT 'searching',
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
  assigned_provider_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  booking_id      UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  completed_at    TIMESTAMPTZ,
  cancelled_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_job_requests_status
  ON public.job_requests (status, created_at DESC);

-- =============================================================
-- DISPATCH OFFERS table
-- =============================================================
CREATE TABLE IF NOT EXISTS public.dispatch_offers (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id        UUID REFERENCES public.job_requests(id) ON DELETE CASCADE NOT NULL,
  provider_id   UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status        TEXT DEFAULT 'pending',
  offered_at    TIMESTAMPTZ DEFAULT now() NOT NULL,
  responded_at  TIMESTAMPTZ
);

-- Idempotent ALTERs for tables that may already exist
-- (Use DO blocks to avoid errors on re-runs)
DO $$
BEGIN
  -- Unique constraint prevents duplicate offers (race-condition guard)
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_dispatch_offers_job_provider'
  ) THEN
    ALTER TABLE public.dispatch_offers
      ADD CONSTRAINT uq_dispatch_offers_job_provider
      UNIQUE (job_id, provider_id);
  END IF;

  -- CHECK constraint ensures valid status values
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_dispatch_offers_status'
  ) THEN
    ALTER TABLE public.dispatch_offers
      ADD CONSTRAINT ck_dispatch_offers_status
      CHECK (status IN ('pending', 'accepted', 'rejected', 'timed_out'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_dispatch_offers_job
  ON public.dispatch_offers (job_id, status);

CREATE INDEX IF NOT EXISTS idx_dispatch_offers_provider
  ON public.dispatch_offers (provider_id, status);

-- =============================================================
-- ROW LEVEL SECURITY
-- =============================================================
ALTER TABLE public.job_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispatch_offers ENABLE ROW LEVEL SECURITY;

-- Clients can read their own job requests
DROP POLICY IF EXISTS job_requests_client_select ON public.job_requests;
CREATE POLICY job_requests_client_select ON public.job_requests
  FOR SELECT
  USING (client_id = auth.uid());

-- Providers can read job requests they have an offer for
DROP POLICY IF EXISTS job_requests_provider_select ON public.job_requests;
CREATE POLICY job_requests_provider_select ON public.job_requests
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.dispatch_offers
      WHERE job_id = id AND provider_id = auth.uid()
    )
  );

-- Clients can insert job requests (their own)
DROP POLICY IF EXISTS job_requests_client_insert ON public.job_requests;
CREATE POLICY job_requests_client_insert ON public.job_requests
  FOR INSERT
  WITH CHECK (client_id = auth.uid());

-- Clients can cancel their own jobs
DROP POLICY IF EXISTS job_requests_client_cancel ON public.job_requests;
CREATE POLICY job_requests_client_cancel ON public.job_requests
  FOR UPDATE
  USING (client_id = auth.uid())
  WITH CHECK (
    client_id = auth.uid()
    AND status IN ('cancelled', 'searching', 'offered')
  );

-- Providers can read their own offers
DROP POLICY IF EXISTS dispatch_offers_provider_select ON public.dispatch_offers;
CREATE POLICY dispatch_offers_provider_select ON public.dispatch_offers
  FOR SELECT
  USING (provider_id = auth.uid());

-- Clients can read offers for their jobs
DROP POLICY IF EXISTS dispatch_offers_client_select ON public.dispatch_offers;
CREATE POLICY dispatch_offers_client_select ON public.dispatch_offers
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.job_requests
      WHERE id = job_id AND client_id = auth.uid()
    )
  );

-- =============================================================
-- FUNCTION: match_best_provider
-- Uses advisory lock to prevent race conditions where two
-- concurrent calls match the same provider.
-- =============================================================
CREATE OR REPLACE FUNCTION match_best_provider(
  p_job_id        UUID,
  p_service_type  TEXT,
  p_lat           DOUBLE PRECISION,
  p_lng           DOUBLE PRECISION
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_provider_id   UUID;
  v_job_location  extensions.geography;
  v_lock_key      BIGINT;
BEGIN
  -- Advisory lock key based on job_id to serialize matching per job
  v_lock_key := ('x' || substr(p_job_id::text, 1, 16))::bit(64)::bigint;
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- If job is no longer in 'searching', another call already handled it
  IF EXISTS (SELECT 1 FROM public.job_requests
             WHERE id = p_job_id AND status != 'searching') THEN
    RETURN NULL;
  END IF;

  -- Convert input lat/lng into a PostGIS geography point
  v_job_location := ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography;

  -- Find the closest available provider whose service category matches
  SELECT p.id INTO v_provider_id
  FROM public.profiles p
  WHERE p.service_category = p_service_type
    AND p.is_available = true
    AND p.location IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM public.dispatch_offers d
      WHERE d.job_id = p_job_id AND d.provider_id = p.id
    )
  ORDER BY p.location <-> v_job_location ASC
  LIMIT 1;

  IF FOUND THEN
    INSERT INTO public.dispatch_offers (job_id, provider_id)
    VALUES (p_job_id, v_provider_id);

    UPDATE public.job_requests
    SET status = 'offered'
    WHERE id = p_job_id;
  END IF;

  RETURN v_provider_id;
END;
$$;

-- =============================================================
-- FUNCTION: reject_offer_and_rematch
-- =============================================================
CREATE OR REPLACE FUNCTION reject_offer_and_rematch(
  p_job_id      UUID,
  p_provider_id UUID
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_job public.job_requests%ROWTYPE;
  v_next_provider UUID;
  v_lock_key BIGINT;
BEGIN
  v_lock_key := ('x' || substr(p_job_id::text, 1, 16))::bit(64)::bigint;
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- Mark existing offer as rejected (only if it's still pending)
  UPDATE public.dispatch_offers
  SET status = 'rejected', responded_at = now()
  WHERE job_id = p_job_id AND provider_id = p_provider_id AND status = 'pending';

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  -- Fetch job details for rematch
  SELECT * INTO v_job FROM public.job_requests WHERE id = p_job_id;
  IF NOT FOUND OR v_job.status NOT IN ('offered', 'searching') THEN
    RETURN NULL;
  END IF;

  -- Match the next best provider
  SELECT match_best_provider(
    p_job_id   := v_job.id,
    p_service_type := v_job.service_type,
    p_lat      := v_job.location_lat,
    p_lng      := v_job.location_lng
  ) INTO v_next_provider;

  RETURN v_next_provider;
END;
$$;

-- =============================================================
-- FUNCTION: accept_offer
-- Guards against stale offers and double-accept via advisory lock.
-- =============================================================
CREATE OR REPLACE FUNCTION accept_offer(
  p_job_id      UUID,
  p_provider_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_lock_key BIGINT;
  v_offer_status TEXT;
  v_job_status public.dispatch_status;
BEGIN
  v_lock_key := ('x' || substr(p_job_id::text, 1, 16))::bit(64)::bigint;
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- Check the job is still in an acceptable state
  SELECT status INTO v_job_status
  FROM public.job_requests WHERE id = p_job_id;
  IF NOT FOUND OR v_job_status IN ('assigned', 'completed', 'timed_out', 'cancelled') THEN
    RETURN FALSE;
  END IF;

  -- Check the offer is still pending
  SELECT status INTO v_offer_status
  FROM public.dispatch_offers
  WHERE job_id = p_job_id AND provider_id = p_provider_id;

  IF v_offer_status IS DISTINCT FROM 'pending' THEN
    RETURN FALSE;
  END IF;

  -- Mark all other pending offers for this job as rejected
  UPDATE public.dispatch_offers
  SET status = 'rejected', responded_at = now()
  WHERE job_id = p_job_id AND status = 'pending';

  -- Accept this offer
  UPDATE public.dispatch_offers
  SET status = 'accepted', responded_at = now()
  WHERE job_id = p_job_id AND provider_id = p_provider_id;

  -- Update job request
  UPDATE public.job_requests
  SET status = 'assigned', assigned_provider_id = p_provider_id
  WHERE id = p_job_id;

  -- If linked to a booking, propagate the assignment
  UPDATE public.bookings b
  SET
    status = 'accepted',
    provider_id = p_provider_id,
    accepted_at = now()
  FROM public.job_requests jr
  WHERE jr.id = p_job_id AND b.id = jr.booking_id;

  RETURN TRUE;
END;
$$;

-- =============================================================
-- FUNCTION: cancel_job (client-side)
-- Rejects all pending offers and marks the job as cancelled.
-- =============================================================
CREATE OR REPLACE FUNCTION cancel_job(
  p_job_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_lock_key BIGINT;
BEGIN
  v_lock_key := ('x' || substr(p_job_id::text, 1, 16))::bit(64)::bigint;
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- Reject all pending offers
  UPDATE public.dispatch_offers
  SET status = 'rejected', responded_at = now()
  WHERE job_id = p_job_id AND status = 'pending';

  -- Mark the job as cancelled
  UPDATE public.job_requests
  SET status = 'cancelled', cancelled_at = now()
  WHERE id = p_job_id AND status IN ('searching', 'offered');

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$;

-- =============================================================
-- TRIGGER: Auto-match on new job_request insert
-- =============================================================
CREATE OR REPLACE FUNCTION trigger_match_on_job_request()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  PERFORM match_best_provider(NEW.id, NEW.service_type, NEW.location_lat, NEW.location_lng);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_job_request_match ON public.job_requests;
CREATE TRIGGER trg_job_request_match
  AFTER INSERT ON public.job_requests
  FOR EACH ROW
  WHEN (NEW.status = 'searching')
  EXECUTE FUNCTION trigger_match_on_job_request();
