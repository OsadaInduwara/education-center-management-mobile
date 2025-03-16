import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/grade_model.dart';
import '../../models/teacher_model.dart';
import '../../models/student_model.dart';
import '../../providers/class_management_provider.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  // Selected IDs for creation/assignment.
  String? _selectedGradeId;
  String? _selectedTeacherId;
  String? _selectedClassId;
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    // Trigger the initial data load.
    Provider.of<ClassManagementProvider>(context, listen: false)
        .fetchInitialData();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Class Management'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCreateClassSection(provider),
                const Divider(height: 30),
                _buildAssignSection(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateClassSection(ClassManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _classNameController,
            decoration: const InputDecoration(labelText: 'Class Name'),
            validator: (val) =>
            val == null || val.isEmpty ? 'Enter class name' : null,
          ),
        ),
        const SizedBox(height: 8),
        // Grade Selection.
        DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text('Select a Grade'),
          items: provider.grades.map((GradeModel grade) {
            return DropdownMenuItem(
              value: grade.id,
              child: Text(grade.gradeName),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedGradeId = val;
              _selectedClassId = null; // Reset class if grade changes.
            });
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        ),
        const SizedBox(height: 10),
        // Teacher Selection.
        DropdownButtonFormField<String>(
          value: _selectedTeacherId,
          hint: const Text('Select a Teacher'),
          items: provider.teachers.map((TeacherModel teacher) {
            return DropdownMenuItem(
              value: teacher.uid,
              child: Text('${teacher.name} (${teacher.email})'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedTeacherId = val);
          },
          validator: (val) => val == null ? 'Please select a teacher' : null,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() &&
                _selectedGradeId != null &&
                _selectedTeacherId != null) {
              await Provider.of<ClassManagementProvider>(context, listen: false)
                  .createClass(
                className: _classNameController.text.trim(),
                teacherId: _selectedTeacherId!,
                gradeId: _selectedGradeId!,
              );
              _classNameController.clear();
            }
          },
          child: const Text('Create Class'),
        ),
      ],
    );
  }

  Widget _buildAssignSection(ClassManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign/Unassign Student to Classes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Grade Dropdown for filtering classes.
        DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text('Select Grade for Assignment'),
          items: provider.grades.map((GradeModel grade) {
            return DropdownMenuItem(
              value: grade.id,
              child: Text(grade.gradeName),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedGradeId = val;
              _selectedClassId = null;
            });
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        ),
        const SizedBox(height: 8),
        // Class Dropdown filtered by selected grade.
        DropdownButtonFormField<String>(
          value: _selectedClassId,
          hint: const Text('Select a Class'),
          items: provider.classes
              .where((ClassModel c) => c.gradeId == _selectedGradeId)
              .map((ClassModel c) {
            return DropdownMenuItem(
              value: c.id,
              child: Text(c.className),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedClassId = val);
          },
          validator: (val) => val == null ? 'Please select a class' : null,
        ),
        const SizedBox(height: 8),
        // Student Dropdown.
        DropdownButtonFormField<String>(
          value: _selectedStudentId,
          hint: const Text('Select a Student'),
          items: provider.students.map((StudentModel s) {
            return DropdownMenuItem(
              value: s.uid,
              child: Text('${s.name} (${s.email})'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedStudentId = val);
          },
        ),
        const SizedBox(height: 16),
        // Buttons for assigning and unassigning.
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_selectedClassId != null &&
                    _selectedStudentId != null &&
                    _selectedGradeId != null) {
                  await provider.assignStudentToClass(
                    studentId: _selectedStudentId!,
                    classId: _selectedClassId!,
                    gradeId: _selectedGradeId!,
                    studentEmail: provider.students
                        .firstWhere((s) => s.uid == _selectedStudentId)
                        .email,
                  );
                }
              },
              child: const Text('Assign'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                if (_selectedClassId != null && _selectedStudentId != null) {
                  await provider.unassignStudentFromClass(
                    studentId: _selectedStudentId!,
                    classId: _selectedClassId!,
                  );
                }
              },
              child: const Text('Unassign'),
            ),
          ],
        ),
      ],
    );
  }
}
