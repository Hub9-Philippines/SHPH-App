-- Add provider_reply column to reviews table
-- Run in Supabase SQL Editor (idempotent)

ALTER TABLE public.reviews
  ADD COLUMN IF NOT EXISTS provider_reply TEXT;

ALTER TABLE public.reviews
  ADD COLUMN IF NOT EXISTS provider_reply_at TIMESTAMPTZ;

-- Providers can update their own reply on reviews for their services
DROP POLICY IF EXISTS reviews_provider_update ON public.reviews;
CREATE POLICY reviews_provider_update ON public.reviews
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.service_listings sl
      WHERE sl.id = reviews.service_listing_id
      AND sl.provider_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.service_listings sl
      WHERE sl.id = reviews.service_listing_id
      AND sl.provider_id = auth.uid()
    )
  );
