# 课管家 / LessonTracker

一套代码支持 **Web / iOS / Android** 三个平台，并通过 **Flutter Flavors** + **GitHub Actions** 实现中国版与国际版的构建与发布。所有发布由 **Git tag** 触发。

## 版本与平台规划

### 版本（Flavors）
- **中国版（cn）**
  - 中文名：课管家
  - 英文名：LessonTracker
  - Android 包名：`com.hidotek.lessontracker.cn`
  - iOS Bundle ID：`com.hidotek.lessontracker.cn`
- **国际版（intl）**
  - 名称：LessonTracker
  - Android 包名：`com.hidotek.lessontracker.en`
  - iOS Bundle ID：`com.hidotek.lessontracker.en`

### 平台
- Web
- iOS
- Android

## Tag 发布规则

使用 Git tag 触发 CI：
- `v1.2.3+cn` → 构建/发布中国版（Web/iOS/Android）
- `v1.2.3+intl` → 构建/发布国际版（Web/iOS/Android）

版本号会从 tag 自动解析：
- `build-name` = `1.2.3`
- `build-number` = GitHub `run_number`

## 构建入口（Flavor Entry Points）

- `lib/main_cn.dart` → 中国版
- `lib/main_intl.dart` → 国际版
- `lib/main.dart` 默认指向 **中国版**（可按需调整）

### 如何切换默认版本
- 运行时用 `-t` 指定入口：
  - `flutter run -t lib/main_intl.dart`
  - `flutter run -t lib/main_cn.dart`
- 或修改 `lib/main.dart` 的默认 flavor

## Web 双子域名部署

采用两个子域名分别部署：
- `cn.yourdomain.com` → 中国版
- `intl.yourdomain.com`（或 `app.yourdomain.com`）→ 国际版

详细步骤见：`docs/deploy_web.md`

## App 是否需要发布两个版本？

需要。由于包名/Bundle ID 不同，属于两个独立应用：
- Android：两个应用
- iOS：两个应用

## 项目结构（核心目录）

```text
lib/
  app_config.dart            # Flavor 配置（版本/语言/默认Locale）
  bootstrap.dart             # 启动流程（Supabase 初始化）
  main_cn.dart               # 中国版入口
  main_intl.dart             # 国际版入口
  main.dart                  # 默认入口（当前指向 cn）
  app.dart                   # App 根入口（从 AppConfig 读取配置）
  core/                      # 公共配置/常量/工具
  data/                      # 数据模型与仓库
  providers/                 # 状态管理
  ui/                        # UI 页面与组件
android/
  app/build.gradle.kts       # Android flavor 配置（cn / intl）
  app/src/cn/                # 中国版资源（app_name / icon）
  app/src/intl/              # 国际版资源（app_name / icon）
# iOS
  Runner.xcodeproj/          # iOS 工程配置（含 Debug-cn/Release-cn/Debug-intl/Release-intl）
  Flutter/Debug-cn.xcconfig  # iOS cn 调试配置
  Flutter/Release-cn.xcconfig
  Flutter/Debug-intl.xcconfig
  Flutter/Release-intl.xcconfig
  Runner/Assets.xcassets/
    AppIconCN.appiconset     # iOS 中国版图标
    AppIconIntl.appiconset   # iOS 国际版图标
.github/workflows/
  build-and-release.yml      # tag 触发的多平台构建
scripts/
  release_tag.ps1            # Windows 打 tag 并推送
  release_tag.sh             # macOS/Linux 打 tag 并推送
```

## 图标与名称

- Android：
  - `android/app/src/cn/res/mipmap-*/ic_launcher.png`
  - `android/app/src/intl/res/mipmap-*/ic_launcher.png`
- iOS：
  - `ios/Runner/Assets.xcassets/AppIconCN.appiconset`
  - `ios/Runner/Assets.xcassets/AppIconIntl.appiconset`

当前图标为默认拷贝版本，请替换为各自品牌图标。

## GitHub Actions（CI）

工作流：`.github/workflows/build-and-release.yml`
- 监听 tag：`v*+cn`、`v*+intl`
- 构建矩阵：web / android / ios + cn / intl
- 版本号来自 tag，构建号来自 `run_number`
- 产物：
  - Web → `build/web/`
  - Android → `build/app/outputs/flutter-apk/*.apk`
  - iOS → `build/ios/ipa/*.ipa`（默认 `--no-codesign`）

## 本地构建示例

```bash
# Web
flutter build web --release -t lib/main_cn.dart
flutter build web --release -t lib/main_intl.dart

# Android
flutter build apk --release --flavor cn -t lib/main_cn.dart
flutter build apk --release --flavor intl -t lib/main_intl.dart

# iOS
flutter build ipa --release --flavor cn -t lib/main_cn.dart
flutter build ipa --release --flavor intl -t lib/main_intl.dart
```

## 主要功能

- 多平台统一 UI 与业务逻辑
- 账户登录与统一认证（当前已接入 Supabase）
- 课程管理、课时记录、提醒等核心功能
- 通过 Flavor 支持区域化/多语言扩展

---

如需新增更多区域版本（如 JP / KR），仅需：
1) 添加新的入口文件（`main_xx.dart`）
2) 在 `app_config.dart` 中追加 flavor 配置
3) 为 Android/iOS 增加对应 flavor 与资源
4) 更新 CI 构建矩阵
