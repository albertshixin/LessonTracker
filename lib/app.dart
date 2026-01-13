import 'package:flutter/material.dart';

import 'core/app_scope.dart';
import 'data/models/course.dart';
import 'data/repositories/in_memory_course_repository.dart';
import 'providers/course_store.dart';
import 'ui/views/course/course_create_page.dart';
import 'ui/views/course/course_detail_page.dart';
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
        seed: [
          Course(
            id: 'seed-1',
            title: '高一数学冲刺班',
            category: '学科辅导',
            totalLessons: 24,
            consumedLessons: 6,
            lessonDurationMinutes: 90,
            startDate: DateTime(2026, 1, 15),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.tuesday,
                  time: ClassTimeOfDay(hour: 19, minute: 0),
                ),
                WeeklyCourseTime(
                  weekday: DateTime.friday,
                  time: ClassTimeOfDay(hour: 19, minute: 0),
                ),
              ],
            ),
          ),
          Course(
            id: 'seed-2',
            title: '创意美术素养',
            category: '艺术素养',
            totalLessons: 16,
            consumedLessons: 3,
            lessonDurationMinutes: 75,
            startDate: DateTime(2025, 12, 20),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.saturday,
                  time: ClassTimeOfDay(hour: 10, minute: 0),
                ),
              ],
            ),
          ),
          Course(
            id: 'seed-3',
            title: '青少年足球体能',
            category: '体育训练',
            totalLessons: 18,
            consumedLessons: 12,
            lessonDurationMinutes: 90,
            startDate: DateTime(2025, 11, 5),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.wednesday,
                  time: ClassTimeOfDay(hour: 17, minute: 30),
                ),
                WeeklyCourseTime(
                  weekday: DateTime.sunday,
                  time: ClassTimeOfDay(hour: 9, minute: 0),
                ),
              ],
            ),
          ),
          Course(
            id: 'seed-4',
            title: 'Python 少儿编程',
            category: '科技编程',
            totalLessons: 20,
            consumedLessons: 5,
            lessonDurationMinutes: 80,
            startDate: DateTime(2026, 1, 10),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.saturday,
                  time: ClassTimeOfDay(hour: 14, minute: 0),
                ),
              ],
            ),
          ),
          Course(
            id: 'seed-5',
            title: '思维与领导力',
            category: '综合素养',
            totalLessons: 12,
            consumedLessons: 2,
            lessonDurationMinutes: 70,
            startDate: DateTime(2026, 2, 1),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.monday,
                  time: ClassTimeOfDay(hour: 18, minute: 30),
                ),
              ],
            ),
          ),
          Course(
            id: 'seed-6',
            title: '少儿日语口语',
            category: '语言文化',
            totalLessons: 15,
            consumedLessons: 4,
            lessonDurationMinutes: 60,
            startDate: DateTime(2026, 1, 8),
            schedule: CourseSchedule(
              repeatPattern: CourseRepeatPattern.weekly,
              weeklySlots: [
                WeeklyCourseTime(
                  weekday: DateTime.thursday,
                  time: ClassTimeOfDay(hour: 16, minute: 0),
                ),
              ],
            ),
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
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1E88E5), // 蓝色科技感基准
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F9FC),
            foregroundColor: Color(0xFF0D47A1),
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: const Color(0xFFEEF4FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
              side: const BorderSide(color: Color(0xFF64B5F6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF0D47A1),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            backgroundColor: const Color(0xFFE3F2FD),
            selectedColor: const Color(0xFF1E88E5),
            labelStyle: const TextStyle(
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        routes: {
          '/': (_) => const HomePage(),
          CourseCreatePage.routeName: (_) => const CourseCreatePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == CourseDetailPage.routeName &&
              settings.arguments is Course) {
            return MaterialPageRoute(
              builder: (_) =>
                  CourseDetailPage(course: settings.arguments as Course),
            );
          }
          return null;
        },
      ),
    );
  }
}
