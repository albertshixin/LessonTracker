# Run Web (International flavor)
$env:FLUTTER_WEB_USE_SKIA = 'false'
flutter run -d chrome -t lib/main_intl.dart --dart-define=FLUTTER_WEB_USE_SKIA=false
