# Supabase Setup Guide for Your Portion App

## Prerequisites
- You already have a Supabase project
- Flutter SDK installed
- GitHub account (for keep-alive workflow)

## Step 1: Database Setup

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `0000*seller_buyer_schema.sql` (any migration file) into the SQL editor
4. Click **Run** to execute the schema
5. Verify all tables are created in the **Table Editor**

## Step 2: Enable Authentication Providers

1. In Supabase dashboard, go to **Authentication** > **Providers**
2. Enable **Email** provider (already enabled by default)
3. Optionally enable **Google** and **Apple** sign-in:
   - For Google: Create OAuth credentials in Google Cloud Console
   - For Apple: Create credentials in Apple Developer Portal
4. Configure redirect URLs for your app

## Step 3: Get Your Supabase Credentials

1. In Supabase dashboard, go to **Settings** > **API**
2. Copy the following:
   - **Project URL** (e.g., `https://your-project.supabase.co`)
   - **anon/public key** (for client-side use)
   - **service_role key** (for backend use - keep this secret!)

## Step 4: Set Up GitHub Secrets (for Keep-Alive)

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret** and add:
   - `SUPABASE_PROJECT_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anon/public key
4. The GitHub Actions workflow will automatically run every Sunday at midnight UTC

## Step 5: Install Supabase in Flutter App

Add to your `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

Run:
```bash
flutter pub get
```

## Step 6: Configure Environment Variables

Create a `.env` file in your Flutter project root:
```env
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
```

Add `.env` to your `.gitignore` to keep credentials secure.

## Step 7: Initialize Supabase in Flutter

Update `lib/main.dart` to initialize Supabase on app startup.

## Step 8: Update Auth Screens

The auth screens will be updated to use Supabase Auth instead of mock implementations.

## Verification

1. Test the keep-alive workflow:
   - Go to **Actions** tab in GitHub
   - Click **Supabase Keep-Alive** workflow
   - Click **Run workflow** to test manually
   - Check that it completes successfully

2. Test Supabase connection in your Flutter app

## Important Notes

- **Supabase free tier is always-on** - it does NOT pause like Neon
- The keep-alive workflow is just for extra assurance
- Never commit your `service_role` key to version control
- Use Row Level Security (RLS) policies to protect data
- The schema includes basic RLS policies - customize as needed

## Next Steps

After setup, you can:
1. Test authentication (signup, login, logout)
2. Create test data in the database
3. Implement additional features (messaging, admin panel, etc.)
4. Customize RLS policies for your specific needs

## Troubleshooting

**Issue**: GitHub Actions workflow fails
- **Solution**: Verify your Supabase credentials in GitHub Secrets are correct

**Issue**: Flutter app can't connect to Supabase
- **Solution**: Check your `.env` file has correct URL and anon key

**Issue**: RLS policies blocking access
- **Solution**: Ensure you're authenticated and policies are correctly configured