import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../class_provider.dart'; // if needed
import '../user_provider.dart';  // if needed

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({Key? key}) : super(key: key);

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _grades = [];

  String? _selectedClassId;
  String? _selectedStudentUid;
  String? _selectedStudentEmail;
  String? _selectedTeacherUid;
  String? _selectedTeacherEmail;
  String? _selectedGradeId; // NEW: Grade selection

  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isFetchingData = true);

    // 1) Fetch all classes.
    final classSnaps = await FirebaseFirestore.instance.collection('classes').get();
    final classes = classSnaps.docs.map((doc) {
      final data = doc.data();
      return {
        'docId': doc.id,
        'className': data['className'] ?? '',
        'gradeId': data['gradeId'], // must be saved when class is created.
      };
    }).toList();

    // 2) Fetch all students from Firestore (role=student).
    final studentSnaps = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final students = studentSnaps.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'email': data['email'] ?? '',
        'name': data['name'] ?? '',
      };
    }).toList();

    // 3) Fetch all teachers from Firestore (role=teacher).
    final teacherSnaps = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .get();

    final teachers = teacherSnaps.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'email': data['email'] ?? '',
        'name': data['name'] ?? '',
      };
    }).toList();

    // 4) Fetch Grades from Firestore.
    final gradeSnaps = await FirebaseFirestore.instance.collection('grades').get();
    final grades = gradeSnaps.docs.map((doc) {
      return {
        'docId': doc.id,
        'gradeName': doc['gradeName'] ?? 'Unnamed Grade',
      };
    }).toList();

    setState(() {
      _classes = classes;
      _students = students;
      _teachers = teachers;
      _grades = grades;
      _isFetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isFetchingData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Create new class form.
            _buildCreateClassSection(isLoading),
            const Divider(height: 30),
            // Assign/Unassign Student to classes.
            _buildAssignSection(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateClassSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _classNameController,
            decoration: const InputDecoration(labelText: 'Class Name'),
            validator: (val) => val == null || val.isEmpty ? 'Enter class name' : null,
          ),
        ),
        const SizedBox(height: 8),
        // Grade Selection (for class creation)
        DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text('Select a Grade'),
          items: _grades.map((grade) {
            return DropdownMenuItem(
              value: grade['docId'] as String,
              child: Text(grade['gradeName']),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedGradeId = val);
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedTeacherUid,
          hint: const Text('Select a Teacher'),
          items: _teachers.map((s) {
            final uid = s['uid'] as String;
            final email = s['email'] ?? '';
            final name = s['name'] ?? '';
            return DropdownMenuItem(
              value: uid,
              child: Text('$name ($email)'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedTeacherUid = val;
              final st = _teachers.firstWhere((x) => x['uid'] == val);
              _selectedTeacherEmail = st['email'];
            });
          },
          validator: (val) => val == null ? 'Please select a teacher' : null,
        ),
        const SizedBox(height: 8),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _createClass,
          child: const Text('Create Class'),
        ),
      ],
    );
  }

  Widget _buildAssignSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign/Unassign Student to Multiple Classes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Grade Dropdown for filtering classes.
        DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text('Select Grade for Assignment'),
          items: _grades.map((grade) {
            return DropdownMenuItem(
              value: grade['docId'] as String,
              child: Text(grade['gradeName']),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedGradeId = val);
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        ),
        const SizedBox(height: 8),
        // Class Dropdown filtered by selected grade.
        DropdownButtonFormField<String>(
          value: _selectedClassId,
          hint: const Text('Select a Class'),
          items: _classes.where((classMap) {
            // Filter classes that have a matching gradeId.
            return classMap['gradeId'] == _selectedGradeId;
          }).map((classMap) {
            final classId = classMap['docId'] as String;
            final className = classMap['className'];
            return DropdownMenuItem(
              value: classId,
              child: Text(className),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedClassId = val;
            });
          },
          validator: (val) => val == null ? 'Please select a class' : null,
        ),
        const SizedBox(height: 8),
        // Student Dropdown.
        DropdownButtonFormField<String>(
          value: _selectedStudentUid,
          hint: const Text('Select a Student'),
          items: _students.map((s) {
            final uid = s['uid'] as String;
            final email = s['email'] ?? '';
            final name = s['name'] ?? '';
            return DropdownMenuItem(
              value: uid,
              child: Text('$name ($email)'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedStudentUid = val;
              final st = _students.firstWhere((x) => x['uid'] == val);
              _selectedStudentEmail = st['email'];
            });
          },
        ),
        const SizedBox(height: 16),
        // Buttons for assigning and unassigning.
        isLoading
            ? const CircularProgressIndicator()
            : Row(
          children: [
            ElevatedButton(
              onPressed: _assignClassInArray,
              child: const Text('Assign'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _unassignClassFromArray,
              child: const Text('Unassign'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      final name = _classNameController.text.trim();
      if (name.isEmpty) return;

      // Validate that a teacher is selected.
      if (_selectedTeacherUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a teacher.')),
        );
        return;
      }
      // Validate that a grade is selected.
      if (_selectedGradeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a grade.')),
        );
        return;
      }

      try {
        // Add doc to 'classes' collection including teacher and grade.
        final docRef = await FirebaseFirestore.instance.collection('classes').add({
          'className': name,
          'classTeacherId': _selectedTeacherUid,
          'gradeId': _selectedGradeId, // saving grade id
          'createdAt': FieldValue.serverTimestamp(),
        });

        _classNameController.clear();

        // Refresh the local classes list.
        await _fetchInitialData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class "$name" created (id = ${docRef.id}).')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating class: $e')),
        );
      }
    }
  }

  /// Assign class (and grade) to the selected student.
  Future<void> _assignClassInArray() async {
    if (_selectedClassId == null || _selectedStudentUid == null || _selectedGradeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select grade, class and student.')),
      );
      return;
    }

    final enrolDoc = FirebaseFirestore.instance
        .collection('enrolments')
        .doc(_selectedStudentUid); // doc ID = user UID

    try {
      await enrolDoc.set({
        'email': _selectedStudentEmail ?? '',
        'classIds': FieldValue.arrayUnion([_selectedClassId]),
        'gradeId': _selectedGradeId, // save grade details
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student assigned to class.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning: $e')),
      );
    }
  }

  /// Unassign class from the selected student.
  Future<void> _unassignClassFromArray() async {
    if (_selectedClassId == null || _selectedStudentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both class and student.')),
      );
      return;
    }

    final enrolDoc = FirebaseFirestore.instance
        .collection('enrolments')
        .doc(_selectedStudentUid);

    try {
      await enrolDoc.update({
        'classIds': FieldValue.arrayRemove([_selectedClassId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student unassigned from class.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unassigning: $e')),
      );
    }
  }
}
