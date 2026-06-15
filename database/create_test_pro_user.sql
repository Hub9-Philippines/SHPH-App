-- SQL Script: Create test pro user for testing provider verification flow
-- This script creates a test user with 'pro' role for testing the verification workflow

-- Note: This script assumes you have auth.users already set up.
-- Replace 'test@example.com' and 'password123' with your desired test credentials

-- Step 1: Create a test user in auth.users (if not exists)
-- Run this in Supabase dashboard or via SQL editor
-- You may need to adjust this based on your existing auth setup

-- Insert test user into profiles table with 'pro' role
-- Replace 'USER_ID_HERE' with the actual UUID from auth.users after creating the user
INSERT INTO profiles (id, email, role, verification_status)
VALUES (
  'USER_ID_HERE',  -- Replace with actual user UUID from auth.users
  'test.pro@example.com',
  'pro',
  'unverified'
)
ON CONFLICT (id) DO UPDATE SET
  role = 'pro',
  verification_status = 'unverified';

-- Alternative: Update existing user to pro role
-- If you already have a test user, run this instead:
-- UPDATE profiles
-- SET role = 'pro', verification_status = 'unverified'
-- WHERE email = 'your-test-email@example.com';

-- Verify the update
SELECT id, email, role, verification_status
FROM profiles
WHERE role = 'pro';
