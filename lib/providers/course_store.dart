import 'package:flutter/foundation.dart';

import '../data/models/course.dart';
import '../data/repositories/course_repository.dart';

class CourseStore extends ChangeNotifier {
  CourseStore({required CourseRepository repository}) : _repository = repository {
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

  void delete(String id) {
    _repository.delete(id);
    refresh();
  }
}
