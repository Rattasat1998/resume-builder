-- Supabase Storage Setup for Resume Images
-- Run this in your Supabase SQL Editor

-- Create a storage bucket for resume images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'resume-images',
    'resume-images',
    true,  -- Public bucket (images can be accessed without auth)
    5242880,  -- 5MB max file size
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

-- Storage policies for resume-images bucket
-- First, drop existing policies if they exist
DROP POLICY IF EXISTS "Public read access for resume images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous update" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous delete" ON storage.objects;

-- Allow anyone to read images (public bucket)
CREATE POLICY "Public read access for resume images"
ON storage.objects FOR SELECT
USING (bucket_id = 'resume-images');

-- ============================================
-- User-based policies (requires authentication)
-- ============================================

-- Allow authenticated users to upload to their folder
-- Images are stored in user folders: {user_id}/{resume_id}/{filename}
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'resume-images'
    AND auth.role() = 'authenticated'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can only update their own images
CREATE POLICY "Users can update own images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'resume-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
    bucket_id = 'resume-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can only delete their own images
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'resume-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

