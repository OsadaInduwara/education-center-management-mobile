// // lib/services/firestore_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/class_model.dart';
// import '../models/grade_model.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   /// Fetch all grades.
//   Future<List<GradeModel>> fetchGrades() async {
//     final snapshot = await _db.collection('grades').get();
//     return snapshot.docs.map((doc) => GradeModel.fromFirestore(doc)).toList();
//   }
//
//   /// Fetch all classes.
//   Future<List<ClassModel>> fetchClasses() async {
//     final snapshot = await _db.collection('classes').get();
//     return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
//   }
//
//   /// Fetch classes for a specific grade.
//   Future<List<ClassModel>> fetchClassesForGrade(String gradeId) async {
//     final snapshot = await _db.collection('classes').where('gradeId', isEqualTo: gradeId).get();
//     return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
//   }
//
//   /// Fetch enrolled students for a given class.
//   Future<List<Map<String, dynamic>>> fetchStudentsForClass(String classId) async {
//     final snapshot = await _db
//         .collection('enrolments')
//         .where('classIds', arrayContains: classId)
//         .get();
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       return {
//         'uid': doc.id,
//         'name': data['name'] ?? 'Unnamed',
//         'email': data['email'] ?? '',
//       };
//     }).toList();
//   }
//
//   /// Submit attendance for a class.
//   Future<void> submitAttendance({
//     required String classId,
//     required String date,
//     required String markedBy,
//     required String note,
//     required Map<String, String> records,
//   }) async {
//     await _db.collection('attendance').doc(classId).set({
//       'classId': classId,
//       'date': date,
//       'markedBy': markedBy,
//       'markedAt': FieldValue.serverTimestamp(),
//       'note': note,
//       'records': records,
//     }, SetOptions(merge: true));
//   }
//
//
// }
