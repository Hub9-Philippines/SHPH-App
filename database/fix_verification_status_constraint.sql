-- Fix the verification_status check constraint to include 'reviewing'
-- This allows the face verification flow to set status to 'reviewing'

-- 1. First, drop the existing check constraint
-- Note: You may need to find the actual constraint name first
ALTER TABLE public.profiles 
DROP CONSTRAINT IF EXISTS profiles_verification_status_check;

-- 2. Add the updated check constraint with all valid statuses
ALTER TABLE public.profiles 
ADD CONSTRAINT profiles_verification_status_check 
CHECK (verification_status IN ('unverified', 'pending', 'reviewing', 'verified', 'rejected'));

-- 3. Verify the constraint was added
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'profiles'::regclass 
AND contype = 'c';
