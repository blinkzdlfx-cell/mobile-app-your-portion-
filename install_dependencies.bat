@echo off
echo ========================================
echo Installing Flutter Dependencies
echo ========================================
echo.

cd mobile-app/your_portion

echo Running flutter pub get...
flutter pub get

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Create a .env file with your Supabase credentials
echo 2. Run the database schema in Supabase SQL Editor
echo 3. Set up GitHub Secrets for keep-alive workflow
echo.
pause