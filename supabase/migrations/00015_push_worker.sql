-- Your Portion: Push worker support (00015)
-- Idempotent — safe to run multiple times.
-- Copy and paste this entire file into your Supabase SQL Editor.

-- 1. Push delivery logs (one row per scheduled daily-push attempt)
CREATE TABLE IF NOT EXISTS push_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  portion_id UUID REFERENCES daily_portions(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'ok' CHECK (status IN ('ok', 'no_portion', 'error')),
  recipients INTEGER NOT NULL DEFAULT 0,
  sent INTEGER NOT NULL DEFAULT 0,
  failed INTEGER NOT NULL DEFAULT 0,
  error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_push_logs_created_at ON push_logs(created_at DESC);

ALTER TABLE push_logs ENABLE ROW LEVEL SECURITY;

-- No RLS policies: write-only audit table; the cloud worker uses the
-- service-role key (bypasses RLS). Admins can inspect via dashboard.

-- 2. Atomic "claim today's portion" — picks the oldest unposted draft and
-- publishes it with today's date. Idempotent: the unique partial index on
-- publish_date (migration 00014) guarantees at most one portion per day, and
-- this function re-checks before claiming. Returns the claimed row (or empty).
CREATE OR REPLACE FUNCTION claim_oldest_portion()
RETURNS TABLE (id UUID, title TEXT, scripture_reference TEXT, content TEXT, publish_date DATE)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  claimed_id UUID;
  today DATE := CURRENT_DATE;
BEGIN
  IF EXISTS (SELECT 1 FROM daily_portions dp WHERE dp.publish_date = today) THEN
    RETURN;
  END IF;

  UPDATE daily_portions
  SET is_published = true, publish_date = today
  WHERE id = (
    SELECT dp.id FROM daily_portions dp
    WHERE dp.is_published = false AND dp.publish_date IS NULL
    ORDER BY dp.created_at ASC
    LIMIT 1
  )
  RETURNING id INTO claimed_id;

  IF claimed_id IS NOT NULL THEN
    RETURN QUERY
      SELECT dp.id, dp.title, dp.scripture_reference, dp.content, dp.publish_date
      FROM daily_portions dp
      WHERE dp.id = claimed_id;
  END IF;
END;
$$;

-- Keep the claim RPC out of anonymous/authenticated reach — only the
-- service-role key (used by the cloud worker) may call it.
REVOKE EXECUTE ON FUNCTION claim_oldest_portion() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION claim_oldest_portion() FROM anon;
REVOKE EXECUTE ON FUNCTION claim_oldest_portion() FROM authenticated;
GRANT EXECUTE ON FUNCTION claim_oldest_portion() TO service_role;