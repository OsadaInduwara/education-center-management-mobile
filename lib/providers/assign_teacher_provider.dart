import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeacherProvider extends ChangeNotifier {
  String? selectedUserId;
  String? selectedUserName;
  String? selectedUserEmail;
  File? selectedImageFile;
  String? downloadUrl;
  bool isLoading = false;

  /// **📌 Fetch users without a role in real-time**
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: '') // Fetch only users with no role
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'] as String,
        'email': doc['email'] as String,
      }).toList();
    });
  }

  /// **📌 Select a user**
  void selectUser(String userId, String userName, String userEmail) {
    selectedUserId = userId;
    selectedUserName = userName;
    selectedUserEmail = userEmail;
    notifyListeners(); // 🔥 Notify UI about state change
  }

  /// **📌 Pick an image**
  Future<void> pickImage(File image) async {
    selectedImageFile = image;
    notifyListeners(); // 🔥 Notify UI
  }

  /// **📌 Assign Teacher**
  Future<void> assignTeacher(BuildContext context) async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    isLoading = true;
    notifyListeners(); // 🔥 Show loading state

    try {
      // **Upload image if selected**
      if (selectedImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('teacher_photos')
            .child('$selectedUserId.jpg');
        await storageRef.putFile(selectedImageFile!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      // **Update Firestore user role**
      await FirebaseFirestore.instance.collection('users').doc(selectedUserId).update({
        'role': 'teacher',
        'photoUrl': downloadUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User assigned as Teacher successfully!')),
      );

      // **Clear selection**
      selectedUserId = null;
      selectedUserName = null;
      selectedUserEmail = null;
      selectedImageFile = null;
      downloadUrl = null;

      notifyListeners(); // 🔥 Notify UI

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners(); // 🔥 Notify UI
    }
  }
}
