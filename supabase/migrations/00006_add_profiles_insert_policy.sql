-- Allow authenticated users to insert their own profile
-- (safety net for cases where the trigger hasn't created it yet)
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
