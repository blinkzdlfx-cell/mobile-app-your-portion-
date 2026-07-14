# Your Portion — Product Requirements Document

## Overview
A faith-centered marketplace and community platform connecting buyers and sellers of farmland, land, houses, apartments, and rooms. Integrates daily devotionals, kingdom projects, and a learning library.

## Target Audience
- Christian community members seeking faith-aligned property investments
- Sellers (individuals, churches, organizations) listing properties
- Buyers browsing, saving, and contacting sellers

## User Roles

### Buyer (default)
- Browse all approved property listings
- Save/favorite properties
- Contact sellers via WhatsApp, phone, or email
- Donate to kingdom projects
- Leave reviews on properties (after engagement)
- Access learning library content

### Seller (requires admin verification)
- All buyer features
- Create, edit, delete own property listings (must be `is_seller_verified = true`)
- Create kingdom projects
- View own listings and projects

### Both (Buyer + Seller combined)
- All features of both roles
- Displayed as "Buyer & Seller" in UI

## User Stories

### Authentication & Onboarding
- User can sign up with email/password, Google, or Apple
- User receives email verification
- User sees onboarding carousel (3 pages: faith, marketplace, kingdom)
- User selects role(s) before entering home
- User can skip role selection and choose later from profile

### Home Screen
- User sees a personalized greeting (Good Morning/Afternoon/Evening + first name)
- User sees "Today's Portion" devotional card
- User can search across properties, projects, and library
- User sees marketplace category grid (Farm Land, Land, Houses, Apt & Rooms)
- User sees featured kingdom project
- Bottom nav: Daily, Market, Kingdom, Profile

### Marketplace
- User can browse property listings with category filter chips
- User can filter by location, type, price range, size, seller, purpose (bottom sheet)
- User can tap a FAB to create a listing (seller-verified only) or see "Become a Seller" CTA
- User sees property cards with: image placeholder, title, location, price, seller, rating, verified badge

### Kingdom Projects
- User can browse active/completed projects
- Seller can create new projects (if verified)
- Projects show: title, description, goal amount, raised amount, progress bar

### Learning Library
- Placeholder screen for faith-based educational content

### Profile & Settings
- User can view and edit profile (name, email, phone, location)
- User can see their role badge
- User can access settings, help & support
- User can sign out

### Daily Portion
- User can read the daily devotional/sermon content

## Non-Functional Requirements
- Material 3 design with Serene Covenant palette
- Inter font family via Google Fonts
- Ambient shadows (0px 10px 30px rgba(0,0,0,0.04))
- 8px baseline grid, 12px input/card radius, 16px elevated card radius
- RLS-protected database with Supabase
- Screen protection in release mode
- Root/jailbreak detection (release builds)
