-- Your Portion: Daily portion reads + reflections
-- Idempotent — safe to run multiple times.
-- Copy and paste this entire file into your Supabase SQL Editor.

-- 1. Portion reads (read-status tracking per user)
CREATE TABLE IF NOT EXISTS portion_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  portion_id UUID NOT NULL REFERENCES daily_portions(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, portion_id)
);

ALTER TABLE portion_reads ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'portion_reads' AND policyname = 'Users can view own portion reads') THEN
    CREATE POLICY "Users can view own portion reads" ON portion_reads FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'portion_reads' AND policyname = 'Users can insert own portion reads') THEN
    CREATE POLICY "Users can insert own portion reads" ON portion_reads FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- 2. Portion reflections (one per user per portion)
CREATE TABLE IF NOT EXISTS portion_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  portion_id UUID NOT NULL REFERENCES daily_portions(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, portion_id)
);

ALTER TABLE portion_reflections ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'portion_reflections' AND policyname = 'Users can view own portion reflections') THEN
    CREATE POLICY "Users can view own portion reflections" ON portion_reflections FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'portion_reflections' AND policyname = 'Users can insert own portion reflections') THEN
    CREATE POLICY "Users can insert own portion reflections" ON portion_reflections FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'portion_reflections' AND policyname = 'Users can update own portion reflections') THEN
    CREATE POLICY "Users can update own portion reflections" ON portion_reflections FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END $$;
