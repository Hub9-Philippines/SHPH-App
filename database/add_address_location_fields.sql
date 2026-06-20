-- Adds optional pinned location fields to the existing addresses table.
-- Run this once in your Supabase SQL editor if the schema cache is missing these columns.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'latitude'
  ) THEN
    ALTER TABLE addresses ADD COLUMN latitude DOUBLE PRECISION;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'longitude'
  ) THEN
    ALTER TABLE addresses ADD COLUMN longitude DOUBLE PRECISION;
  END IF;
END $$;

COMMENT ON COLUMN addresses.latitude IS 'Pinned latitude for the address location';
COMMENT ON COLUMN addresses.longitude IS 'Pinned longitude for the address location';
