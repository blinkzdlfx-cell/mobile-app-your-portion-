-- Your Portion 00013: avatars storage bucket + RLS, reviews self-delete,
-- profiles self-delete (account deletion), phone column check.
-- Idempotent. Run in Supabase SQL Editor (or `supabase db push`).

-- ========== 1. AVATARS BUCKET ==========
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Give users access to their own avatar" ON storage.objects;
CREATE POLICY "Give users access to their own avatar"
ON storage.objects FOR ALL
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Public read avatars" ON storage.objects;
CREATE POLICY "Public read avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- ========== 2. REVIEWS SELF-DELETE POLICY ==========
-- 00001 defined SELECT/INSERT/UPDATE for reviews but no DELETE policy.
DROP POLICY IF EXISTS "Reviewers can delete own review" ON reviews;
CREATE POLICY "Reviewers can delete own review"
ON reviews FOR DELETE USING (auth.uid() = reviewer_id);

-- ========== 3. PROFILES SELF-DELETE POLICY (account deletion) ==========
-- Other tables reference profiles(id) ON DELETE CASCADE, so deleting the
-- profile row cleans up all user data; the auth user is removed by the
-- delete-account edge function.
DROP POLICY IF EXISTS "Users can delete own profile" ON profiles;
CREATE POLICY "Users can delete own profile"
ON profiles FOR DELETE USING (auth.uid() = id);