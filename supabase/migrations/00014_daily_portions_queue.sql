-- 00014: Daily portions write-ahead queue
-- Supports the "admin writes ahead, cron posts one per day" flow:
--   - drafts must NOT default to today's date (they are unposted until the cron claims them)
--   - a unique partial index on publish_date guarantees idempotency so the cron
--     can never post two portions for the same day

ALTER TABLE daily_portions
  ALTER COLUMN publish_date SET DEFAULT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS daily_portions_publish_date_unique
  ON daily_portions (publish_date)
  WHERE publish_date IS NOT NULL;
