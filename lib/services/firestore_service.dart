import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Check user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
    } catch (e) {
      rethrow;
    }
    return null; // if not found
  }

  // Example: fetch classes
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    QuerySnapshot snapshot = await _db.collection('classes').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Example: fetch classes for a specific student
  Future<List<Map<String, dynamic>>> getStudentClasses(String studentId) async {
    // e.g., store an array of classIDs in the user's doc, then get them
    // or keep it simpler with subcollections - your choice
    // Implementation depends on your data structure
    return [];
  }

// More methods: createClass, updateClass, deleteClass, registerStudent, etc.
}
