import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GradesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _grades = [];

  List<Map<String, dynamic>> get grades => _grades;

  /// **📌 Real-time Stream for Grades**
  Stream<List<Map<String, dynamic>>> get gradesStream {
    return _firestore.collection('grades').snapshots().map((querySnapshot) {
      _grades = querySnapshot.docs.map((doc) {
        return {
          'gradeId': doc.id,
          'gradeName': doc['gradeName'],
        };
      }).toList();
      return _grades;
    });
  }

  /// **📌 Add or Update a Grade**
  Future<void> createOrUpdateGrade({String? gradeId, required String gradeName}) async {
    try {
      if (gradeId == null) {
        // **Create new grade**
        final docRef = await _firestore.collection('grades').add({'gradeName': gradeName});
        await docRef.update({'gradeId': docRef.id});
      } else {
        // **Update existing grade**
        await _firestore.collection('grades').doc(gradeId).update({'gradeName': gradeName});
      }
    } catch (e) {
      throw Exception("Error updating grade: $e");
    }
  }

  /// **📌 Delete a Grade**
  Future<void> deleteGrade(String gradeId) async {
    try {
      await _firestore.collection('grades').doc(gradeId).delete();
    } catch (e) {
      throw Exception("Error deleting grade: $e");
    }
  }
}
