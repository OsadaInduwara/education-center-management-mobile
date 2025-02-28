import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _classes = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get classes => _classes;

  /// Create a new class doc in Firestore
  Future<void> createClass(String className) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.collection('classes').add({
        'className': className,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating class: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all classes (used by manager)
  Future<void> getAllClasses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('classes').get();
      _classes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // add the doc ID to the map
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching all classes: $e');
      _classes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch classes for a specific student
  /// (Assuming 'studentIds' array in each class doc)
  Future<void> getStudentClasses(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('classes')
          .where('studentIds', arrayContains: uid)
          .get();

      _classes = snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('Error fetching student classes: $e');
      _classes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
