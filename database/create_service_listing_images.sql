-- Service Listing Images Table
-- Multi-image gallery support for service listings
-- Ported from web app's ServiceListingImage model

CREATE TABLE IF NOT EXISTS service_listing_images (
    id          BIGSERIAL PRIMARY KEY,
    listing_id  BIGINT NOT NULL REFERENCES service_listings(id) ON DELETE CASCADE,
    image_url   TEXT NOT NULL,
    sort_order  INT NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for fast lookup by listing
CREATE INDEX IF NOT EXISTS idx_service_listing_images_listing_id
    ON service_listing_images(listing_id);

-- Index for ordering
CREATE INDEX IF NOT EXISTS idx_service_listing_images_sort_order
    ON service_listing_images(listing_id, sort_order);

-- RLS Policies
ALTER TABLE service_listing_images ENABLE ROW LEVEL SECURITY;

-- Anyone can view images (public service listings)
DROP POLICY IF EXISTS "Anyone can view listing images" ON service_listing_images;
CREATE POLICY "Anyone can view listing images"
    ON service_listing_images FOR SELECT
    USING (true);

-- Providers can insert images for their own listings
DROP POLICY IF EXISTS "Providers can insert own listing images" ON service_listing_images;
CREATE POLICY "Providers can insert own listing images"
    ON service_listing_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM service_listings sl
            WHERE sl.id = listing_id
            AND sl.provider = auth.uid()
        )
    );

-- Providers can update images for their own listings
DROP POLICY IF EXISTS "Providers can update own listing images" ON service_listing_images;
CREATE POLICY "Providers can update own listing images"
    ON service_listing_images FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM service_listings sl
            WHERE sl.id = listing_id
            AND sl.provider = auth.uid()
        )
    );

-- Providers can delete images for their own listings
DROP POLICY IF EXISTS "Providers can delete own listing images" ON service_listing_images;
CREATE POLICY "Providers can delete own listing images"
    ON service_listing_images FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM service_listings sl
            WHERE sl.id = listing_id
            AND sl.provider = auth.uid()
        )
    );

-- Admins can manage all listing images
DROP POLICY IF EXISTS "Admins can manage all listing images" ON service_listing_images;
CREATE POLICY "Admins can manage all listing images"
    ON service_listing_images FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.is_admin = true
        )
    );
