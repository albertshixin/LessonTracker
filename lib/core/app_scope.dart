import 'package:flutter/widgets.dart';

import '../providers/course_store.dart';

class AppScope extends InheritedNotifier<CourseStore> {
  const AppScope({
    super.key,
    required CourseStore store,
    required super.child,
  }) : super(notifier: store);

  static CourseStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found. Wrap MaterialApp with AppScope.');
    return scope!.notifier!;
  }
}
