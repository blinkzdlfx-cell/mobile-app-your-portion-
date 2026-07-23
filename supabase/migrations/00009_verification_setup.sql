-- Your Portion: Complete seller verification setup
-- Idempotent — safe to run multiple times.
-- Copy and paste this entire file into your Supabase SQL Editor.

-- 1. Verification requests table
CREATE TABLE IF NOT EXISTS verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  request_type TEXT NOT NULL CHECK (request_type IN ('seller', 'trusted_member')),
  full_name TEXT,
  phone TEXT,
  reason TEXT,
  id_document_url TEXT,
  id_type TEXT CHECK (id_type IN ('nin', 'voter_card', 'international_passport')),
  face_image_url TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_note TEXT,
  reviewed_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Indexes (skip if exist)
CREATE INDEX IF NOT EXISTS idx_verification_requests_user_id ON verification_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status ON verification_requests(status);
CREATE INDEX IF NOT EXISTS idx_verification_requests_type ON verification_requests(request_type);

-- 3. Row-level security
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'Users can view own requests') THEN
    CREATE POLICY "Users can view own requests" ON verification_requests FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'Users can create requests') THEN
    CREATE POLICY "Users can create requests" ON verification_requests FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'Admins can view all requests') THEN
    CREATE POLICY "Admins can view all requests" ON verification_requests FOR SELECT USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'Admins can update requests') THEN
    CREATE POLICY "Admins can update requests" ON verification_requests FOR UPDATE USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
  END IF;
END $$;

-- 4. Add missing columns (safe if already exist)
ALTER TABLE verification_requests ADD COLUMN IF NOT EXISTS id_document_url TEXT;
ALTER TABLE verification_requests ADD COLUMN IF NOT EXISTS id_type TEXT CHECK (id_type IN ('nin', 'voter_card', 'international_passport'));
ALTER TABLE verification_requests ADD COLUMN IF NOT EXISTS face_image_url TEXT;

-- 5. Storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('verification_documents', 'verification_documents', false)
ON CONFLICT (id) DO NOTHING;

-- 6. Storage policies (drop first so re-run is safe)
DROP POLICY IF EXISTS "Users can upload own verification documents" ON storage.objects;
CREATE POLICY "Users can upload own verification documents"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'verification_documents'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Users can read own verification documents" ON storage.objects;
CREATE POLICY "Users can read own verification documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'verification_documents'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

DROP POLICY IF EXISTS "Admins can read all verification documents" ON storage.objects;
CREATE POLICY "Admins can read all verification documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'verification_documents'
  AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
