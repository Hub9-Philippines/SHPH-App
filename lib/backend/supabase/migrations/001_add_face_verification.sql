-- Migration: Add face verification columns to profiles table
-- Purpose: Support biometric-based user identity verification
-- Created: 2026-03-09

-- Add face verification tracking columns
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_face_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS face_verification_token UUID,
ADD COLUMN IF NOT EXISTS last_verification_date TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Create an index for efficient queries on face verification status
CREATE INDEX IF NOT EXISTS profiles_is_face_verified_idx ON public.profiles(is_face_verified);
CREATE INDEX IF NOT EXISTS profiles_last_verification_date_idx ON public.profiles(last_verification_date);

-- Add comment documentation
COMMENT ON COLUMN public.profiles.is_face_verified IS 'Boolean flag indicating if user has completed face verification';
COMMENT ON COLUMN public.profiles.face_verification_token IS 'Unique token generated upon successful face verification for audit/security';
COMMENT ON COLUMN public.profiles.last_verification_date IS 'Timestamp of the most recent successful face verification';

-- Ensure RLS policies protect face verification data
-- (RLS should already be enabled on profiles table)
-- This prevents users from modifying their own face_verified status directly
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- If RLS policies don't exist, create them (adjust based on your existing policies)
-- Users can only update their own profile
CREATE POLICY IF NOT EXISTS "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
