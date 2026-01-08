import 'package:flutter/material.dart';

import 'core/app_scope.dart';
import 'data/models/course.dart';
import 'data/repositories/in_memory_course_repository.dart';
import 'providers/course_store.dart';
import 'ui/views/course/course_create_page.dart';
import 'ui/views/home/home_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final CourseStore _store;

  @override
  void initState() {
    super.initState();
    _store = CourseStore(
      repository: InMemoryCourseRepository(
        seed: const [
          Course(
            id: 'seed-1',
            title: '雅马哈钢琴课',
            category: '音乐',
            totalLessons: 20,
            consumedLessons: 1,
          ),
          Course(
            id: 'seed-2',
            title: '少儿英语一对一',
            category: '学科',
            totalLessons: 30,
            consumedLessons: 24,
          ),
          Course(
            id: 'seed-3',
            title: '足球训练营',
            category: '运动',
            totalLessons: 12,
            consumedLessons: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: MaterialApp(
        title: '课管家',
        theme: ThemeData(useMaterial3: true),
        routes: {
          '/': (_) => const HomePage(),
          CourseCreatePage.routeName: (_) => const CourseCreatePage(),
        },
      ),
    );
  }
}
