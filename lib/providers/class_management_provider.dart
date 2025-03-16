import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/grade_model.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';

class ClassManagementProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = false;
  List<ClassModel> classes = [];
  List<StudentModel> students = [];
  List<TeacherModel> teachers = [];
  List<GradeModel> grades = [];

  /// Fetch all initial data.
  Future<void> fetchInitialData() async {
    isLoading = true;
    notifyListeners();
    try {
      // Fetch classes.
      final classSnap = await _db.collection('classes').get();
      classes = classSnap.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();

      // Fetch students (role = student).
      final studentSnap = await _db.collection('users').where('role', isEqualTo: 'student').get();
      students = studentSnap.docs
          .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
          .toList();

      // Fetch teachers (role = teacher).
      final teacherSnap = await _db.collection('users').where('role', isEqualTo: 'teacher').get();
      teachers = teacherSnap.docs
          .map((doc) => TeacherModel.fromMap(doc.data(), doc.id))
          .toList();

      // Fetch grades.
      final gradeSnap = await _db.collection('grades').get();
      grades = gradeSnap.docs.map((doc) => GradeModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching initial data: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new class.
  Future<void> createClass({
    required String className,
    required String teacherId,
    required String gradeId,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final docRef = await _db.collection('classes').add({
        'className': className,
        'classTeacherId': teacherId,
        'gradeId': gradeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await docRef.update({'classId': docRef.id});
      // Refresh data after creation.
      await fetchInitialData();
    } catch (e) {
      debugPrint("Error creating class: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Assign a student to a class.
  Future<void> assignStudentToClass({
    required String studentId,
    required String classId,
    required String gradeId,
    required String studentEmail,
  }) async {
    try {
      final enrolDoc = _db.collection('enrolments').doc(studentId);
      await enrolDoc.set({
        'email': studentEmail,
        'classIds': FieldValue.arrayUnion([classId]),
        'gradeId': gradeId,
      }, SetOptions(merge: true));
      await enrolDoc.update({'userId': enrolDoc.id});
    } catch (e) {
      debugPrint("Error assigning student: $e");
      rethrow;
    }
  }

  /// Unassign a student from a class.
  Future<void> unassignStudentFromClass({
    required String studentId,
    required String classId,
  }) async {
    try {
      final enrolDoc = _db.collection('enrolments').doc(studentId);
      await enrolDoc.update({
        'classIds': FieldValue.arrayRemove([classId])
      });
    } catch (e) {
      debugPrint("Error unassigning student: $e");
      rethrow;
    }
  }
}
