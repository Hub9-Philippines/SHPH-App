-- Adds the payment_status field to the bookings table.
-- Run this once in Supabase if the schema cache is missing the column.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'bookings' AND column_name = 'payment_status'
  ) THEN
    ALTER TABLE bookings ADD COLUMN payment_status TEXT DEFAULT 'pending';
  END IF;
END $$;

COMMENT ON COLUMN bookings.payment_status IS 'Payment state for the booking flow';
