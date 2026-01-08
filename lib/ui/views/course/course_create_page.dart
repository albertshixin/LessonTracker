import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../data/models/course.dart';

class CourseCreatePage extends StatefulWidget {
  const CourseCreatePage({super.key});

  static const routeName = '/course/create';

  @override
  State<CourseCreatePage> createState() => _CourseCreatePageState();
}

class _CourseCreatePageState extends State<CourseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalController = TextEditingController(text: '20');
  final _consumedController = TextEditingController(text: '0');

  String _category = '音乐';

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _consumedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建课程'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '课程名称',
                      hintText: '例如：钢琴课 / 英语一对一',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return '请输入课程名称';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: const [
                      DropdownMenuItem(value: '音乐', child: Text('音乐')),
                      DropdownMenuItem(value: '学科', child: Text('学科')),
                      DropdownMenuItem(value: '运动', child: Text('运动')),
                      DropdownMenuItem(value: '艺术', child: Text('艺术')),
                      DropdownMenuItem(value: '其他', child: Text('其他')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _category = v);
                    },
                    decoration: const InputDecoration(
                      labelText: '类型标签',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _totalController,
                          decoration: const InputDecoration(
                            labelText: '总课时',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            final value = double.tryParse((v ?? '').trim());
                            if (value == null) return '请输入数字';
                            if (value <= 0) return '必须大于 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _consumedController,
                          decoration: const InputDecoration(
                            labelText: '已上课时（可选）',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            final value = double.tryParse((v ?? '').trim());
                            if (value == null) return '请输入数字';
                            if (value < 0) return '不能小于 0';
                            final total = double.tryParse(_totalController.text.trim());
                            if (total != null && value > total) return '不能大于总课时';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.check),
                      label: const Text('创建'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final title = _titleController.text.trim();
    final total = double.parse(_totalController.text.trim());
    final consumed = double.parse(_consumedController.text.trim());

    final store = AppScope.of(context);
    store.create(
      CourseDraft(
        title: title,
        category: _category,
        totalLessons: total,
        consumedLessons: consumed,
      ),
    );

    Navigator.of(context).pop();
  }
}
