import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../class_provider.dart'; // This provider returns each class with 'id'

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // Selected grade and class IDs from dropdowns.
  String? _selectedGradeId;
  String? _selectedClassId;

  // Attendance date, default to today (format: yyyy-MM-dd).
  late final String _attendanceDate;

  // For attendance form:
  List<Map<String, dynamic>> _students = [];
  // Map of studentUid -> "present" or "absent".
  Map<String, String> _attendanceRecords = {};

  // Optional note field controller.
  final _noteController = TextEditingController();

  bool _isLoading = false; // Local loading flag

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _attendanceDate =
    "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Fetch the list of enrolled students for the selected class.
  Future<void> _fetchStudentsForClass(String classId) async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('enrolments')
          .where('classIds', arrayContains: classId)
          .get();

      final List<Map<String, dynamic>> fetchedStudents = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'email': data['email'] ?? '',
        };
      }).toList();

      setState(() {
        _students = fetchedStudents;
        // Initialize attendance: default to "absent".
        _attendanceRecords = {};
        for (var student in fetchedStudents) {
          _attendanceRecords[student['uid']] = 'absent';
        }
      });
    } catch (e) {
      debugPrint("Error fetching students: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Bulk action: mark all students as present.
  void _markAllPresent() {
    setState(() {
      _attendanceRecords.updateAll((key, value) => "present");
    });
  }

  /// Bulk action: mark all students as absent.
  void _markAllAbsent() {
    setState(() {
      _attendanceRecords.updateAll((key, value) => "absent");
    });
  }

  /// Submit attendance: Save a document to the "attendance" collection using the class ID as the doc ID.
  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedClassId == null) {
        throw Exception("No class selected");
      }
      // Use current user's UID for 'markedBy'
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found");
      }
      final markedBy = currentUser.uid;

      await FirebaseFirestore.instance.collection('attendance').doc(_selectedClassId).set({
        'classId': _selectedClassId,
        'date': _attendanceDate,
        'markedBy': markedBy,
        'markedAt': FieldValue.serverTimestamp(),
        'note': _noteController.text.trim(),
        'records': _attendanceRecords,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error saving attendance: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Build the grade dropdown.
  Widget _buildGradeDropdown() {
    // For simplicity, we fetch grades directly here.
    // In production you might want to use a provider.
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('grades').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final gradeDocs = snapshot.data!.docs;
        final gradeItems = gradeDocs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(doc['gradeName']),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: _selectedGradeId,
          hint: const Text("Select a Grade"),
          items: gradeItems,
          onChanged: (val) {
            setState(() {
              _selectedGradeId = val;
              // Clear any previously selected class if the grade changes.
              _selectedClassId = null;
            });
          },
          validator: (val) => val == null ? 'Please select a grade' : null,
        );
      },
    );
  }

  /// Build the class dropdown, filtered by selected grade.
  Widget _buildClassDropdown() {
    final classProvider = Provider.of<ClassProvider>(context);
    final classes = classProvider.classes; // Each map includes 'id', 'className', and 'gradeId'.
    // Filter classes by selected grade.
    final filteredClasses = _selectedGradeId != null
        ? classes.where((c) => c['gradeId'] == _selectedGradeId).toList()
        : [];
    final List<DropdownMenuItem<String>> dropdownItems = [];
    final Set<String> seenIds = {};
    for (var classData in filteredClasses) {
      final classId = classData['id'];
      if (classId != null && !seenIds.contains(classId)) {
        seenIds.add(classId);
        final className = classData['className'] ?? "Unnamed Class";
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: classId,
            child: Text(className),
          ),
        );
      }
    }
    final String? dropdownValue =
    (_selectedClassId != null && seenIds.contains(_selectedClassId))
        ? _selectedClassId
        : null;
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      hint: const Text("Select a Class"),
      items: dropdownItems,
      onChanged: (val) {
        setState(() {
          _selectedClassId = val;
        });
        if (val != null) {
          _fetchStudentsForClass(val);
        }
      },
      validator: (val) => val == null ? 'Please select a class' : null,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        onPressed: _markAllPresent,
                        child: const Text("All Present"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _markAllAbsent,
                        child: const Text("All Absent"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _students.isEmpty
                      ? const Text("No students found for this class.")
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final uid = student['uid']!;
                      final name = student['name'];
                      final email = student['email'];
                      final status = _attendanceRecords[uid] ?? "absent";
                      return ListTile(
                        title: Text("$name ($email)"),
                        trailing: Switch(
                          value: status == "present",
                          onChanged: (val) {
                            setState(() {
                              _attendanceRecords[uid] =
                              val ? "present" : "absent";
                            });
                          },
                        ),
                      );
                    },
                  ),
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
                      onPressed: _submitAttendance,
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
