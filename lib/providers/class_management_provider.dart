import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/grade_model.dart';
import '../models/user_model.dart';

class ClassManagementProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = false;
  List<ClassModel> classes = [];
  List<UserModel> teachers = [];
  List<UserModel> students = [];

  List<GradeModel> grades = [];

  /// Fetch all initial data.
  Future<void> fetchInitialData() async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        _db.collection('classes').get().then((snap) {
          classes = snap.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
        }),
        _db.collection('users').where('role', isEqualTo: 'student').get().then((snap) {
          students = snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
        }),
        _db.collection('users').where('role', isEqualTo: 'teacher').get().then((snap) {
          teachers = snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
        }),
        _db.collection('grades').get().then((snap) {
          grades = snap.docs.map((doc) => GradeModel.fromFirestore(doc)).toList();
        }),
      ]);
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
        'userId': studentId, // Include userId here
      }, SetOptions(merge: true));
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
