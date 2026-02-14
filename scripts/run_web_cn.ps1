# Run Web (China flavor)
$env:FLUTTER_WEB_USE_SKIA = 'false'
flutter run -d chrome -t lib/main_cn.dart --dart-define=FLUTTER_WEB_USE_SKIA=false
