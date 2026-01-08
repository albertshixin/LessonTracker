import '../models/course.dart';

abstract class CourseRepository {
  List<Course> list();
  Course create(CourseDraft draft);
  void update(Course course);
  void delete(String id);
}
