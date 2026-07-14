-- Your Portion: Complete Base Schema
-- Run this in your Supabase SQL editor (first time only)

-- 1. Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  location TEXT,
  role TEXT NOT NULL DEFAULT 'buyer' CHECK (role IN ('buyer', 'seller', 'both', 'admin')),
  is_seller_verified BOOLEAN NOT NULL DEFAULT false,
  is_trusted_member BOOLEAN NOT NULL DEFAULT false,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Daily Portions table
CREATE TABLE daily_portions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  scripture_reference TEXT,
  category TEXT DEFAULT 'devotional',
  is_published BOOLEAN DEFAULT false,
  publish_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Properties table
CREATE TABLE properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL, -- 'Farm Land', 'Land', 'Houses', 'Apartments', 'Rooms'
  price NUMERIC NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  location TEXT NOT NULL,
  size_sqm NUMERIC,
  bedrooms INT,
  bathrooms INT,
  images TEXT[] DEFAULT '{}',
  contact_whatsapp TEXT,
  contact_phone TEXT,
  contact_email TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  rejection_reason TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Saved properties (favorites)
CREATE TABLE saved_properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, property_id)
);

-- 5. Kingdom projects
CREATE TABLE kingdom_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  goal_amount NUMERIC,
  raised_amount NUMERIC NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'active', 'completed', 'rejected'
  rejection_reason TEXT,
  contact_whatsapp TEXT,
  contact_phone TEXT,
  contact_email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Project donations
CREATE TABLE project_donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES kingdom_projects(id) ON DELETE CASCADE,
  donor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(property_id, reviewer_id)
);

-- ============ INDEXES ============

CREATE INDEX idx_properties_seller_id ON properties(seller_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_saved_properties_user_id ON saved_properties(user_id);
CREATE INDEX idx_kingdom_projects_creator_id ON kingdom_projects(creator_id);
CREATE INDEX idx_kingdom_projects_status ON kingdom_projects(status);
CREATE INDEX idx_project_donations_project_id ON project_donations(project_id);
CREATE INDEX idx_reviews_property_id ON reviews(property_id);

-- ============ AUTO-UPDATE UPDATED_AT ============

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_kingdom_projects_updated_at
  BEFORE UPDATE ON kingdom_projects
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============ RLS POLICIES ============

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_portions ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE kingdom_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- ========== PROFILES ==========
-- Everyone can read profiles
CREATE POLICY "Anyone can view profiles"
  ON profiles FOR SELECT USING (true);

-- Users can update own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Admins can update any profile
CREATE POLICY "Admins can update any profile"
  ON profiles FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Trigger: auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, NEW.raw_user_meta_data->>'email'),
    NEW.raw_user_meta_data->>'full_name',
    COALESCE(NEW.raw_user_meta_data->>'role', 'buyer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========== DAILY PORTIONS ==========
-- Anyone can view published daily portions
CREATE POLICY "Anyone can view published portions"
  ON daily_portions FOR SELECT USING (is_published = true);

-- ========== PROPERTIES ==========
-- Anyone can view approved properties; sellers view own; admins view all
CREATE POLICY "Anyone can view approved properties"
  ON properties FOR SELECT USING (
    status = 'approved'
    OR seller_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Sellers can insert own properties (must be seller-verified by admin)
CREATE POLICY "Sellers can insert properties"
  ON properties FOR INSERT WITH CHECK (
    auth.uid() = seller_id
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_seller_verified = true)
  );

-- Sellers can update own properties; admins can update any
CREATE POLICY "Sellers can update own properties"
  ON properties FOR UPDATE USING (
    seller_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Sellers can delete own properties; admins can delete any
CREATE POLICY "Sellers can delete own properties"
  ON properties FOR DELETE USING (
    seller_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ========== SAVED PROPERTIES ==========
-- Users can view own saves
CREATE POLICY "Users can view own saved properties"
  ON saved_properties FOR SELECT USING (auth.uid() = user_id);

-- Users can save
CREATE POLICY "Users can save properties"
  ON saved_properties FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can unsave
CREATE POLICY "Users can unsave properties"
  ON saved_properties FOR DELETE USING (auth.uid() = user_id);

-- ========== KINGDOM PROJECTS ==========
-- Anyone can view active/completed projects; creators view own; admins view all
CREATE POLICY "Anyone can view active projects"
  ON kingdom_projects FOR SELECT USING (
    status IN ('active', 'completed')
    OR creator_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Verified sellers can create projects
CREATE POLICY "Sellers can create projects"
  ON kingdom_projects FOR INSERT WITH CHECK (
    auth.uid() = creator_id
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_seller_verified = true)
  );

-- Creators can update own projects; admins can update any
CREATE POLICY "Creators can update own projects"
  ON kingdom_projects FOR UPDATE USING (
    creator_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Creators can delete own projects; admins can delete any
CREATE POLICY "Creators can delete own projects"
  ON kingdom_projects FOR DELETE USING (
    creator_id = auth.uid()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ========== DONATIONS ==========
-- Anyone can view donations
CREATE POLICY "Anyone can view donations"
  ON project_donations FOR SELECT USING (true);

-- Buyers can donate
CREATE POLICY "Buyers can donate"
  ON project_donations FOR INSERT WITH CHECK (auth.uid() = donor_id);

-- ========== REVIEWS ==========
-- Anyone can view reviews
CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT USING (true);

-- Buyers can review properties
CREATE POLICY "Buyers can review"
  ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Reviewers can update own review
CREATE POLICY "Reviewers can update own review"
  ON reviews FOR UPDATE USING (auth.uid() = reviewer_id);
