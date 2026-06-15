-- SQL Script: Create Supabase Storage bucket for provider verification documents
-- This creates a secure private bucket for storing ID scans and face selfies

-- Create the storage bucket (run this in Supabase SQL editor or via Supabase dashboard)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'provider-verification',
  'provider-verification',
  false, -- Private bucket - not publicly accessible
  5242880, -- 5MB file size limit
  ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/heic']
)
ON CONFLICT (id) DO NOTHING;

-- Create Row Level Security policies for the bucket

-- Policy: Allow authenticated users to upload to their own folder
DROP POLICY IF EXISTS "Users can upload to own verification folder" ON storage.objects;
CREATE POLICY "Users can upload to own verification folder" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'provider-verification'
    AND auth.uid()::text = (storage.foldername(name))[1]
    AND (
      -- Allow uploading to documents folder
      (storage.foldername(name))[2] = 'documents'
      OR
      -- Allow uploading to faces folder
      (storage.foldername(name))[2] = 'faces'
    )
  );

-- Policy: Allow users to read their own uploaded files
DROP POLICY IF EXISTS "Users can read own verification files" ON storage.objects;
CREATE POLICY "Users can read own verification files" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'provider-verification'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Allow service role (admin) to read all verification files for review
DROP POLICY IF EXISTS "Service role can read all verification files" ON storage.objects;
CREATE POLICY "Service role can read all verification files" ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'provider-verification'
    AND auth.role() = 'service_role'
  );

-- Policy: Allow service role to delete verification files
DROP POLICY IF EXISTS "Service role can delete verification files" ON storage.objects;
CREATE POLICY "Service role can delete verification files" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'provider-verification'
    AND auth.role() = 'service_role'
  );

-- Note: This bucket stores provider verification documents (ID scans and face selfies)
-- Files are organized as: {user_id}/documents/ or {user_id}/faces/
