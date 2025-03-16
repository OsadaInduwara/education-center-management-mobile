// lib/providers/attendance_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool isLoading = false;

  // List of students enrolled in the selected class.
  List<Map<String, dynamic>> students = [];

  // Map of studentUid -> "present" or "absent".
  Map<String, String> attendanceRecords = {};

  /// Fetch students enrolled in a given class.
  Future<void> fetchStudentsForClass(String classId) async {
    isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot snap = await _db
          .collection('enrolments')
          .where('classIds', arrayContains: classId)
          .get();

      students = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'email': data['email'] ?? '',
        };
      }).toList();

      // Initialize attendanceRecords with default "absent" status.
      attendanceRecords = { for (var student in students) student['uid']: 'absent' };
    } catch (e) {
      debugPrint("Error fetching students: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Mark all students as present.
  void markAllPresent() {
    attendanceRecords.updateAll((key, value) => "present");
    notifyListeners();
  }

  /// Mark all students as absent.
  void markAllAbsent() {
    attendanceRecords.updateAll((key, value) => "absent");
    notifyListeners();
  }

  /// Update attendance for a single student.
  void updateAttendance(String uid, bool isPresent) {
    attendanceRecords[uid] = isPresent ? "present" : "absent";
    notifyListeners();
  }

  /// Submit attendance data.
  Future<void> submitAttendance({
    required String classId,
    required String date,
    required String note,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Not authenticated");
      final markedBy = currentUser.uid;

      // Create an instance of AttendanceModel with current data.
      final attendance = AttendanceModel(
        classId: classId,
        date: date,
        markedBy: markedBy,
        markedAt: DateTime.now(),
        note: note,
        records: attendanceRecords,
      );

      // Save the attendance data to Firestore.
      await _db.collection('attendance').doc(classId).set(
        attendance.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint("Error submitting attendance: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
