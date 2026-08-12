-- Your Portion: Device tokens for push notifications
-- Idempotent — safe to run multiple times.
-- Copy and paste this entire file into your Supabase SQL Editor.

-- 1. Device tokens table (FCM registration tokens per user)
CREATE TABLE IF NOT EXISTS device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'android',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);

-- 3. Row-level security
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_tokens' AND policyname = 'Users can view own device tokens') THEN
    CREATE POLICY "Users can view own device tokens" ON device_tokens FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_tokens' AND policyname = 'Users can insert own device tokens') THEN
    CREATE POLICY "Users can insert own device tokens" ON device_tokens FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_tokens' AND policyname = 'Users can update own device tokens') THEN
    CREATE POLICY "Users can update own device tokens" ON device_tokens FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'device_tokens' AND policyname = 'Users can delete own device tokens') THEN
    CREATE POLICY "Users can delete own device tokens" ON device_tokens FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;
