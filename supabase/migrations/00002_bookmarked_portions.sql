-- Your Portion: Bookmarked Portions
-- Run this after 00001_seller_buyer_schema.sql

CREATE TABLE IF NOT EXISTS bookmarked_portions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  portion_id UUID NOT NULL REFERENCES daily_portions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, portion_id)
);

ALTER TABLE bookmarked_portions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bookmarks"
  ON bookmarked_portions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can bookmark"
  ON bookmarked_portions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove own bookmarks"
  ON bookmarked_portions FOR DELETE USING (auth.uid() = user_id);
