#!/bin/bash
set -e

export PATH="$PATH:$HOME/development/flutter/bin"

SUPABASE_URL="https://dittsxxflcityahxrfej.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpdHRzeHhmbGNpdHlhaHhyZmVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NDYyNzYsImV4cCI6MjA5MjUyMjI3Nn0.US-3pE6fFKrgEpGpbwc2jHioyADjMPUOki-P7i1MeYc"
# API сервер байхгүй — wallet/QR/AI ErrorView харуулна
API_BASE_URL="https://api.siop.mn/v1"

echo "=== Flutter version ==="
flutter --version

echo "=== pub get ==="
flutter pub get

echo "=== Building IPA for TestFlight ==="
flutter build ipa \
  --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --export-options-plist=ios/ExportOptions.plist

echo ""
echo "=== Build complete! ==="
echo "IPA байршил: build/ios/ipa/*.ipa"
echo ""
echo "Дараагийн алхам: Xcode → Window → Organizer → Distribute App"
echo "эсвэл: xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey ... --apiIssuer ..."
