#!/bin/bash
# Play Store-д зориулсан Android App Bundle (AAB) build хийх script
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

# === Шалгалт ===
if [ ! -f "android/app/upload-keystore.jks" ]; then
  echo "❌ Keystore олдсонгүй. Эхлэж ажиллуул:"
  echo "   bash setup_android_signing.sh"
  exit 1
fi

if grep -q "REPLACE_WITH_ANDROID_APP_ID" "android/app/google-services.json" 2>/dev/null; then
  echo "❌ google-services.json-г Firebase Console-аас татаж оруулаагүй байна."
  echo "   Firebase Console → cop17-ub2026 → Android app нэмэх → google-services.json татах"
  echo "   Файл байршил: android/app/google-services.json"
  exit 1
fi

echo "=== Flutter version ==="
flutter --version

echo ""
echo "=== pub get ==="
flutter pub get

echo ""
echo "=== Android icons үүсгэж байна ==="
dart run flutter_launcher_icons

REVIEW_EMAIL=$(python3 -c "import json; d=json.load(open('dart_defines.json')); print(d.get('REVIEW_EMAIL',''))" 2>/dev/null || echo "${REVIEW_EMAIL:-}")
REVIEW_CODE=$(python3 -c "import json; d=json.load(open('dart_defines.json')); print(d.get('REVIEW_CODE',''))" 2>/dev/null || echo "${REVIEW_CODE:-}")

echo ""
echo "=== Building Android App Bundle (release) ==="
flutter build appbundle \
  --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=DEMO_MODE=false \
  --dart-define=REVIEW_EMAIL="$REVIEW_EMAIL" \
  --dart-define=REVIEW_CODE="$REVIEW_CODE"

echo ""
echo "=== Build амжилттай! ==="
echo ""
echo "AAB файл байршил:"
echo "  build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Дараагийн алхам:"
echo "  1. play.google.com/console руу нэвтэр"
echo "  2. App → Production → Create new release"
echo "  3. app-release.aab файлыг upload хий"
echo "  4. Release notes (МН + EN) бөглө"
echo "  5. Review → Submit"
