// lib/models/attendance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String classId;
  final String date;
  final String markedBy;
  final DateTime markedAt;
  final String note;
  final Map<String, String> records;

  AttendanceModel({
    required this.classId,
    required this.date,
    required this.markedBy,
    required this.markedAt,
    required this.note,
    required this.records,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      classId: data['classId'] ?? '',
      date: data['date'] ?? '',
      markedBy: data['markedBy'] ?? '',
      markedAt: data['markedAt'] != null
          ? (data['markedAt'] as Timestamp).toDate()
          : DateTime.now(),
      note: data['note'] ?? '',
      records: Map<String, String>.from(data['records'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'date': date,
      'markedBy': markedBy,
      'markedAt': markedAt != null ? Timestamp.fromDate(markedAt) : FieldValue.serverTimestamp(),
      'note': note,
      'records': records,
    };
  }
}
