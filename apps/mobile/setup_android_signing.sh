#!/bin/bash
# Android upload keystore setup
# Нэг удаа л ажиллуулна — keystore аль хэдийн байвал skip хийнэ.
set -e

KEYSTORE="android/app/upload-keystore.jks"
KEY_PROPS="android/key.properties"

if [ -f "$KEYSTORE" ]; then
  echo "✅ Keystore аль хэдийн байна: $KEYSTORE"
  exit 0
fi

echo "=== Upload keystore үүсгэж байна ==="

keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass siop2026upload \
  -keypass siop2026upload \
  -dname "CN=SIOP Asia 2026, OU=Mobile, O=SIOP Mongolia, L=Ulaanbaatar, ST=Ulaanbaatar, C=MN"

echo ""
echo "✅ Keystore үүслээ: $KEYSTORE"
echo ""
echo "⚠️  ЧУХАЛ: Энэ файлыг хамгаалж нөөцлөх хэрэгтэй!"
echo "   Хаа нэг газар аюулгүй хадгала (Google Drive / 1Password / USB)."
echo "   Алдвал Play Store-д шинэ build upload хийж чадахгүй болно."
echo ""
echo "key.properties:"
cat "$KEY_PROPS"
