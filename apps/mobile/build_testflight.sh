#!/bin/bash
set -e

export PATH="$PATH:$HOME/development/flutter/bin"

# === Load secrets from dart_defines.json (gitignored) or environment variables ===
if [ -f "dart_defines.json" ]; then
  SUPABASE_URL=$(python3 -c "import json; print(json.load(open('dart_defines.json'))['SUPABASE_URL'])")
  SUPABASE_ANON_KEY=$(python3 -c "import json; print(json.load(open('dart_defines.json'))['SUPABASE_ANON_KEY'])")
  API_BASE_URL=$(python3 -c "import json; d=json.load(open('dart_defines.json')); print(d.get('API_BASE_URL','https://api.siop.mn/v1'))")
else
  SUPABASE_URL="${SUPABASE_URL:?dart_defines.json not found and SUPABASE_URL env var not set}"
  SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:?dart_defines.json not found and SUPABASE_ANON_KEY env var not set}"
  API_BASE_URL="${API_BASE_URL:-https://api.siop.mn/v1}"
fi

echo "=== Flutter version ==="
flutter --version

echo "=== pub get ==="
flutter pub get

REVIEW_EMAIL=$(python3 -c "import json; d=json.load(open('dart_defines.json')); print(d.get('REVIEW_EMAIL',''))" 2>/dev/null || echo "${REVIEW_EMAIL:-}")
REVIEW_CODE=$(python3 -c "import json; d=json.load(open('dart_defines.json')); print(d.get('REVIEW_CODE',''))" 2>/dev/null || echo "${REVIEW_CODE:-}")

echo "=== Building IPA for TestFlight ==="
flutter build ipa \
  --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=REVIEW_EMAIL="$REVIEW_EMAIL" \
  --dart-define=REVIEW_CODE="$REVIEW_CODE" \
  --export-options-plist=ios/ExportOptions.plist

echo ""
echo "=== Build complete! ==="
echo "IPA байршил: build/ios/ipa/*.ipa"
echo ""
echo "Дараагийн алхам: Xcode → Window → Organizer → Distribute App"
echo "эсвэл: xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey ... --apiIssuer ..."
