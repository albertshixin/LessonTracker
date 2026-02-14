import 'package:flutter/widgets.dart';

enum AppFlavor {
  cn,
  intl,
}

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.displayName,
    required this.appName,
    required this.defaultLocale,
  });

  final AppFlavor flavor;
  final String displayName;
  final String appName;
  final Locale defaultLocale;

  bool get isChina => flavor == AppFlavor.cn;

  static AppConfig forFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.cn:
        return const AppConfig(
          flavor: AppFlavor.cn,
          displayName: '课管家',
          appName: 'LessonTracker',
          defaultLocale: Locale('zh', 'CN'),
        );
      case AppFlavor.intl:
        return const AppConfig(
          flavor: AppFlavor.intl,
          displayName: 'LessonTracker',
          appName: 'LessonTracker',
          defaultLocale: Locale('en'),
        );
    }
  }
}

class AppConfigScope extends InheritedWidget {
  const AppConfigScope({
    super.key,
    required this.config,
    required super.child,
  });

  final AppConfig config;

  static AppConfig of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppConfigScope>();
    assert(scope != null, 'AppConfigScope not found in widget tree.');
    return scope!.config;
  }

  @override
  bool updateShouldNotify(AppConfigScope oldWidget) =>
      config.flavor != oldWidget.config.flavor ||
      config.displayName != oldWidget.config.displayName ||
      config.appName != oldWidget.config.appName ||
      config.defaultLocale != oldWidget.config.defaultLocale;
}
