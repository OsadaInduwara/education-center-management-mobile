// // lib/models/enrollment_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class EnrollmentModel {
//   final String userId;
//   final List<String> classIds;
//   final String email;
//   final String gradeId;
//
//   EnrollmentModel({
//     required this.userId,
//     required this.classIds,
//     required this.email,
//     required this.gradeId,
//   });
//
//   factory EnrollmentModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return EnrollmentModel(
//       userId: doc.id,
//       classIds: List<String>.from(data['classIds'] ?? []),
//       email: data['email'] ?? '',
//       gradeId: data['gradeId'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'classIds': classIds,
//       'email': email,
//       'gradeId': gradeId,
//     };
//   }
// }
