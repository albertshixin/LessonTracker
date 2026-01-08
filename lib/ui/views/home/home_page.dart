import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../data/models/course.dart';
import '../../widgets/course_card.dart';
import '../course/course_create_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const _AppBrandTitle(),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: '搜索（待实现）',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 900 ? 24.0 : 16.0;
            return AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final courses = store.courses;

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 88),
                  itemCount: courses.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _Header(theme: theme, count: courses.length);
                    }

                    final course = courses[index - 1];
                    return CourseCard(
                      data: _toCardData(course),
                      onTap: () {},
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(CourseCreatePage.routeName);
        },
        icon: const Icon(Icons.add),
        label: const Text('新建课程'),
      ),
    );
  }

  CourseCardData _toCardData(Course course) {
    final now = DateTime.now();
    final remaining = course.remainingLessons;
    final total = course.totalLessons;

    final expiringByRemaining = remaining <= 2;
    final expiringByDate = course.endDate != null && course.endDate!.difference(now).inDays <= 7;

    return CourseCardData(
      title: course.title,
      category: course.category,
      remaining: remaining,
      total: total,
      nextLessonLabel: '下一次：未设置（下一步做排课）',
      isExpiring: expiringByRemaining || expiringByDate,
    );
  }
}

class _AppBrandTitle extends StatelessWidget {
  const _AppBrandTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '课管家',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '您的课程提醒全能助手',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.count});

  final ThemeData theme;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你的课程（$count）',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterChip(label: '全部', selected: true),
              _FilterChip(label: '即将到期'),
              _FilterChip(label: '本周有课'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final foreground = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
