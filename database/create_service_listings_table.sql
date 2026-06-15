-- Create service_listings table
CREATE TABLE IF NOT EXISTS service_listings (
  id SERIAL PRIMARY KEY,
  category INTEGER,
  category_name TEXT,
  provider INTEGER,
  provider_name TEXT,
  provider_photo TEXT,
  title TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC,
  price_unit TEXT,
  status TEXT,
  is_available TEXT,
  rating TEXT,
  thumbnail TEXT,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_service_listings_category ON service_listings(category);
CREATE INDEX IF NOT EXISTS idx_service_listings_provider ON service_listings(provider);
CREATE INDEX IF NOT EXISTS idx_service_listings_rating ON service_listings(rating DESC);
CREATE INDEX IF NOT EXISTS idx_service_listings_created_at ON service_listings(created_at DESC);

-- Enable Row Level Security
ALTER TABLE service_listings ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view service listings
CREATE POLICY "Anyone can view service listings"
  ON service_listings FOR SELECT
  USING (true);

-- Policy: Authenticated users can insert service listings
CREATE POLICY "Authenticated users can insert service listings"
  ON service_listings FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Policy: Service providers can update their own listings
CREATE POLICY "Providers can update own listings"
  ON service_listings FOR UPDATE
  USING (auth.uid()::text = provider::text);

-- Policy: Service providers can delete their own listings
CREATE POLICY "Providers can delete own listings"
  ON service_listings FOR DELETE
  USING (auth.uid()::text = provider::text);
