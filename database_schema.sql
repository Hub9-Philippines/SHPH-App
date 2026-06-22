-- Add a geography column for provider location and index it
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS location GEOGRAPHY(Point, 4326);
CREATE INDEX IF NOT EXISTS idx_provider_location ON profiles USING GIST (location);

