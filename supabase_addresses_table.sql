-- Add PSGC code columns to existing addresses table
-- This script adds PSGC geographic code columns to an existing addresses table
-- Run this in your Supabase SQL Editor

-- Add PSGC code columns if they don't exist
DO $$
BEGIN
  -- Add region_code column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'region_code'
  ) THEN
    ALTER TABLE addresses ADD COLUMN region_code VARCHAR(20);
  END IF;

  -- Add province_code column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'province_code'
  ) THEN
    ALTER TABLE addresses ADD COLUMN province_code VARCHAR(20);
  END IF;

  -- Add city_municipality_code column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'city_municipality_code'
  ) THEN
    ALTER TABLE addresses ADD COLUMN city_municipality_code VARCHAR(20);
  END IF;

  -- Add barangay_code column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'addresses' AND column_name = 'barangay_code'
  ) THEN
    ALTER TABLE addresses ADD COLUMN barangay_code VARCHAR(20);
  END IF;
END $$;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_addresses_region_code ON addresses(region_code);
CREATE INDEX IF NOT EXISTS idx_addresses_province_code ON addresses(province_code);
CREATE INDEX IF NOT EXISTS idx_addresses_city_municipality_code ON addresses(city_municipality_code);
CREATE INDEX IF NOT EXISTS idx_addresses_barangay_code ON addresses(barangay_code);
CREATE INDEX IF NOT EXISTS idx_addresses_is_default ON addresses(user_id, is_default);

-- Add RLS (Row Level Security) policies
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist, then recreate them
DROP POLICY IF EXISTS "Users can view own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can insert own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can update own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can delete own addresses" ON addresses;

-- Policy: Users can only see their own addresses
CREATE POLICY "Users can view own addresses"
  ON addresses FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own addresses
CREATE POLICY "Users can insert own addresses"
  ON addresses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own addresses
CREATE POLICY "Users can update own addresses"
  ON addresses FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own addresses
CREATE POLICY "Users can delete own addresses"
  ON addresses FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists, then recreate it
DROP TRIGGER IF EXISTS update_addresses_updated_at ON addresses;
CREATE TRIGGER update_addresses_updated_at
  BEFORE UPDATE ON addresses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to ensure only one default address per user
CREATE OR REPLACE FUNCTION ensure_single_default_address()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_default = true THEN
    UPDATE addresses
    SET is_default = false
    WHERE user_id = NEW.user_id AND id != NEW.id AND is_default = true;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists, then recreate it
DROP TRIGGER IF EXISTS ensure_single_default_address_trigger ON addresses;
CREATE TRIGGER ensure_single_default_address_trigger
  BEFORE INSERT OR UPDATE ON addresses
  FOR EACH ROW
  WHEN (NEW.is_default = true)
  EXECUTE FUNCTION ensure_single_default_address();

-- Comment on table
COMMENT ON TABLE addresses IS 'User addresses with PSGC geographic codes';

-- Comments on PSGC code columns
COMMENT ON COLUMN addresses.region_code IS 'PSGC region code (e.g., 130000000 for NCR)';
COMMENT ON COLUMN addresses.province_code IS 'PSGC province code (e.g., 012800000 for Ilocos Norte)';
COMMENT ON COLUMN addresses.city_municipality_code IS 'PSGC city/municipality code (e.g., 012805000)';
COMMENT ON COLUMN addresses.barangay_code IS 'PSGC barangay code (e.g., 012805001)';
