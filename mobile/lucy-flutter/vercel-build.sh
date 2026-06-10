#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --dart-define=LUCY_AUTH_API_URL="${LUCY_AUTH_API_URL}" \
  --dart-define=LUCY_PAYMENT_API_URL="${LUCY_PAYMENT_API_URL}" \
  --dart-define=LUCY_LMS_API_URL="${LUCY_LMS_API_URL}" \
  --dart-define=LUCY_REALTIME_URL="${LUCY_REALTIME_URL}"