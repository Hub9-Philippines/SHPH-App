-- Add face_scan_submitted_at column to profiles table
-- This tracks when the user submitted their face verification scan

-- Add the column
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS face_scan_submitted_at TIMESTAMP WITH TIME ZONE;

-- Add comment for documentation
COMMENT ON COLUMN public.profiles.face_scan_submitted_at IS 'Timestamp when user submitted face verification scan';

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'profiles'
AND column_name = 'face_scan_submitted_at';
