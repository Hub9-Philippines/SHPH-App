-- Migration: Add role and verification fields to profiles table
-- This script adds fields for role-based access control and provider verification tracking

-- Add role column (ENUM constraint for 'client' or 'pro')
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'client',
ADD CONSTRAINT check_role CHECK (role IN ('client', 'pro'));

-- Add verification_status column (ENUM constraint for verification states)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'unverified',
ADD CONSTRAINT check_verification_status CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected'));

-- Add document_url column for storing ID scan file path
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS document_url TEXT;

-- Add face_scan_url column for storing biometric selfie file path
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS face_scan_url TEXT;

-- Add timestamps for verification tracking
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Create index on role for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Create index on verification_status for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_verification_status ON profiles(verification_status);

-- Create composite index for verified providers
CREATE INDEX IF NOT EXISTS idx_profiles_verified_providers ON profiles(role, verification_status) 
WHERE role = 'pro' AND verification_status = 'verified';

-- Update Row Level Security policies
-- Allow users to read their own profile data
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT
  USING (auth.uid()::text = id);

-- Allow users to update their own profile (for verification submission)
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE
  USING (auth.uid()::text = id)
  WITH CHECK (auth.uid()::text = id);

-- Allow service role (admin) to update verification status
DROP POLICY IF EXISTS "Service role can update verification" ON profiles;
CREATE POLICY "Service role can update verification" ON profiles
  FOR UPDATE
  USING (auth.role() = 'service_role');

-- Comment on columns for documentation
COMMENT ON COLUMN profiles.role IS 'User role: ''client'' for service seekers, ''pro'' for service providers';
COMMENT ON COLUMN profiles.verification_status IS 'Verification status for providers: ''unverified'', ''pending'', ''verified'', ''rejected''';
COMMENT ON COLUMN profiles.document_url IS 'Storage URL for uploaded government ID document';
COMMENT ON COLUMN profiles.face_scan_url IS 'Storage URL for biometric face scan selfie';
COMMENT ON COLUMN profiles.submitted_at IS 'Timestamp when verification was submitted';
COMMENT ON COLUMN profiles.reviewed_at IS 'Timestamp when verification was reviewed';
COMMENT ON COLUMN profiles.rejection_reason IS 'Reason for verification rejection if applicable';
