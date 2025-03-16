// lib/screens/manager/mark_attendance_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // Selected grade and class IDs.
  String? _selectedGradeId;
  String? _selectedClassId;

  // Attendance date, default to today.
  late final String _attendanceDate;

  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _attendanceDate =
    "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Build grade dropdown (using FutureBuilder for simplicity).
  Widget _buildGradeDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('grades').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final gradeDocs = snapshot.data!.docs;
        final gradeItems = gradeDocs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(
              doc['gradeName']
            ),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text("Select a Grade"),
          items: gradeItems,
          onChanged: (val) {
            setState(() {
              _selectedGradeId = val;
              _selectedClassId = null;
            });
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        );
      },
    );
  }

  /// Build class dropdown filtered by selected grade.
  Widget _buildClassDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('classes').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final classDocs = snapshot.data!.docs;
        final classes = classDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Use ClassModel for type-safety
          return ClassModel.fromFirestore(doc);
        }).toList();

        final filteredClasses = _selectedGradeId != null
            ? classes.where((c) => c.gradeId == _selectedGradeId).toList()
            : <ClassModel>[];

        final List<DropdownMenuItem<String>> dropdownItems = filteredClasses.map((classModel) {
          return DropdownMenuItem<String>(
            value: classModel.id,
            child: Text(classModel.className),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: _selectedClassId,
          hint: const Text("Select a Class"),
          items: dropdownItems,
          onChanged: (val) {
            setState(() {
              _selectedClassId = val;
            });
            if (val != null) {
              Provider.of<AttendanceProvider>(context, listen: false)
                  .fetchStudentsForClass(val);
            }
          },
          validator: (val) => val == null ? 'Please select a class' : null,
        );
      },
    );
  }

  /// Build student list with attendance toggles.
  Widget _buildStudentList() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProv, child) {
        if (attendanceProv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (attendanceProv.students.isEmpty) {
          return const Text("No students found for this class.");
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attendanceProv.students.length,
          itemBuilder: (context, index) {
            final student = attendanceProv.students[index];
            final uid = student['uid']!;
            final name = student['name'];
            final email = student['email'];
            final status = attendanceProv.attendanceRecords[uid] ?? "absent";
            return ListTile(
              title: Text("$name ($email)"),
              trailing: Switch(
                value: status == "present",
                onChanged: (val) {
                  attendanceProv.updateAttendance(uid, val);
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Build the main UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradeDropdown(),
            const SizedBox(height: 16),
            _buildClassDropdown(),
            const SizedBox(height: 16),
            if (_selectedClassId != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance for Class $_selectedClassId on $_attendanceDate",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Provider.of<AttendanceProvider>(context, listen: false)
                                .markAllPresent(),
                        child: const Text("All Present"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () =>
                            Provider.of<AttendanceProvider>(context, listen: false)
                                .markAllAbsent(),
                        child: const Text("All Absent"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStudentList(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await Provider.of<AttendanceProvider>(context, listen: false)
                              .submitAttendance(
                            classId: _selectedClassId!,
                            date: _attendanceDate,
                            note: _noteController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Attendance saved successfully!")),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      },
                      child: const Text("Submit Attendance"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
