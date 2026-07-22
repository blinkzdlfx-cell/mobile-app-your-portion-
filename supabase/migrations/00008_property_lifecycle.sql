-- Add status constraint to allow draft/archived lifecycle
ALTER TABLE properties
DROP CONSTRAINT IF EXISTS properties_status_check;

ALTER TABLE properties
ADD CONSTRAINT properties_status_check
CHECK (status IN ('draft', 'pending', 'approved', 'rejected', 'archived'));

-- Update RLS: allow creators to see their own draft/archived properties
DROP POLICY IF EXISTS "Anyone can view approved properties" ON properties;

CREATE POLICY "Anyone can view approved properties"
ON properties FOR SELECT
USING (
  status = 'approved'
  OR seller_id = auth.uid()
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Add 'rejection_reason' column if not exists (should already exist)
ALTER TABLE properties
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
