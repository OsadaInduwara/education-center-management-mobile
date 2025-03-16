import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String className;
  final String classTeacherId;
  final String gradeId;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.className,
    required this.classTeacherId,
    required this.gradeId,
    required this.createdAt,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      className: data['className'] ?? '',
      classTeacherId: data['classTeacherId'] ?? '',
      gradeId: data['gradeId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'classTeacherId': classTeacherId,
      'gradeId': gradeId,
      'createdAt': FieldValue.serverTimestamp(),
      'classId': id, // In case you want to store the doc id
    };
  }
}
