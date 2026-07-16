-- Add id_document_url column for seller single-document verification
ALTER TABLE verification_requests
ADD COLUMN id_document_url TEXT;

-- Create storage bucket for verification documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('verification_documents', 'verification_documents', false)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own documents
CREATE POLICY "Users can upload own verification documents"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'verification_documents'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to read their own documents
CREATE POLICY "Users can read own verification documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'verification_documents'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow admins to read all verification documents
CREATE POLICY "Admins can read all verification documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'verification_documents'
  AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
