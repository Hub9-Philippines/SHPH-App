-- Fix RLS policies for provider-verification storage bucket
-- This allows authenticated users to upload/download their own verification files

-- 1. Enable RLS on the storage.objects table (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies on storage.objects for the bucket (if any)
DROP POLICY IF EXISTS "Allow users to upload their own verification files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to read their own verification files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update their own verification files" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete their own verification files" ON storage.objects;

-- 3. Create policy: Allow authenticated users to INSERT (upload) files to their own folder
CREATE POLICY "Allow users to upload their own verification files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'provider-verification' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 4. Create policy: Allow authenticated users to SELECT (read/download) their own files
CREATE POLICY "Allow users to read their own verification files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'provider-verification'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Create policy: Allow authenticated users to UPDATE their own files
CREATE POLICY "Allow users to update their own verification files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'provider-verification'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'provider-verification'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 6. Create policy: Allow authenticated users to DELETE their own files
CREATE POLICY "Allow users to delete their own verification files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'provider-verification'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 7. Allow admins to access all files in the bucket (backend/admin use only)
DROP POLICY IF EXISTS "Allow admins full access to verification files" ON storage.objects;

CREATE POLICY "Allow admins full access to verification files"
ON storage.objects FOR ALL
TO authenticated
USING (
  bucket_id = 'provider-verification'
  AND EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  )
);

-- Verify the policies were created
SELECT policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE '%verification%';
