import 'package:cloud_firestore/cloud_firestore.dart';

class GradeModel {
  final String id;
  final String gradeName;

  GradeModel({
    required this.id,
    required this.gradeName,
  });

  factory GradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GradeModel(
      id: doc.id,
      gradeName: data['gradeName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gradeName': gradeName,
      'gradeId': id,
    };
  }
}
