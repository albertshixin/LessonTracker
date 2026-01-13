import 'package:flutter/foundation.dart';

import '../data/models/course.dart';
import '../data/repositories/course_repository.dart';

class CourseStore extends ChangeNotifier {
  CourseStore({required CourseRepository repository})
      : _repository = repository {
    _courses = _repository.list();
  }

  final CourseRepository _repository;
  late List<Course> _courses;

  List<Course> get courses => List.unmodifiable(_courses);

  void refresh() {
    _courses = _repository.list();
    notifyListeners();
  }

  Course create(CourseDraft draft) {
    final created = _repository.create(draft);
    refresh();
    return created;
  }

  void update(Course course) {
    _repository.update(course);
    refresh();
  }

  void checkIn(String courseId, DateTime sessionStart, {bool makeUp = false}) {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;
    final course = _courses[index];

    // 已经打过卡则忽略
    final dateOnly = DateTime(sessionStart.year, sessionStart.month, sessionStart.day);
    final hasAttended = course.attendanceRecords.any((r) =>
        r.status == AttendanceStatus.attended &&
        r.sessionStart.year == dateOnly.year &&
        r.sessionStart.month == dateOnly.month &&
        r.sessionStart.day == dateOnly.day);
    if (hasAttended) return;

    final delta = makeUp ? -1 : 1;
    final newConsumed = (course.consumedLessons + delta)
        .clamp(0, course.totalLessons)
        .toDouble();

    final updated = course.copyWith(
      consumedLessons: newConsumed,
      attendanceRecords: _upsertAttendance(
        course.attendanceRecords,
        CourseAttendanceRecord(
          sessionStart: sessionStart,
          status: AttendanceStatus.attended,
        ),
      ),
    );

    update(updated);
  }

  void removeCheckIn(String courseId, DateTime sessionStart) {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;
    final course = _courses[index];

    final targetDate =
        DateTime(sessionStart.year, sessionStart.month, sessionStart.day);

    final existedAttended = course.attendanceRecords.any((r) =>
        r.status == AttendanceStatus.attended &&
        r.sessionStart.year == targetDate.year &&
        r.sessionStart.month == targetDate.month &&
        r.sessionStart.day == targetDate.day);
    if (!existedAttended) return;

    final updatedRecords = course.attendanceRecords.where((r) {
      final sameDay = r.sessionStart.year == targetDate.year &&
          r.sessionStart.month == targetDate.month &&
          r.sessionStart.day == targetDate.day;
      return !(sameDay && r.status == AttendanceStatus.attended);
    }).toList();

    final newConsumed =
        (course.consumedLessons - 1).clamp(0, course.totalLessons).toDouble();

    final updated = course.copyWith(
      consumedLessons: newConsumed,
      attendanceRecords: updatedRecords,
    );
    update(updated);
  }

  void setLeave(String courseId, DateTime sessionStart, {required bool leave}) {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;
    final course = _courses[index];

    List<CourseAttendanceRecord> nextRecords;
    if (leave) {
      nextRecords = _upsertAttendance(
        course.attendanceRecords,
        CourseAttendanceRecord(
          sessionStart: sessionStart,
          status: AttendanceStatus.leave,
        ),
      );
    } else {
      // 取消请假：移除该天的请假记录
      nextRecords = course.attendanceRecords.where((r) {
        final sameDay = r.sessionStart.year == sessionStart.year &&
            r.sessionStart.month == sessionStart.month &&
            r.sessionStart.day == sessionStart.day;
        return !(sameDay && r.status == AttendanceStatus.leave);
      }).toList();
    }

    final updated = course.copyWith(attendanceRecords: nextRecords);
    update(updated);
  }

  List<CourseAttendanceRecord> _upsertAttendance(
    List<CourseAttendanceRecord> list,
    CourseAttendanceRecord record,
  ) {
    final sameDay = (CourseAttendanceRecord r) =>
        r.sessionStart.year == record.sessionStart.year &&
        r.sessionStart.month == record.sessionStart.month &&
        r.sessionStart.day == record.sessionStart.day;

    final filtered = list.where((r) => !sameDay(r)).toList();
    return [...filtered, record];
  }

  void delete(String id) {
    _repository.delete(id);
    refresh();
  }
}
