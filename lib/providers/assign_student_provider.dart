import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StudentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> allUsers = []; // Store all users in memory
  List<String> selectedUserIds = []; // Selected students
  Map<String, String> selectedUserPhotos = {}; // Store user images
  bool isLoading = false;
  String searchQuery = ''; // Search filter
  Timer? _debounce; // Debounce timer

  StudentProvider() {
    fetchUsers(); // Fetch users initially
  }

  /// **📌 Fetch users without a role in real-time**
  void fetchUsers() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: '')
        .snapshots()
        .listen((querySnapshot) {
      allUsers = querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'] as String,
        'email': doc['email'] as String,
      }).toList();
      notifyListeners(); // 🔥 Notify UI
    });
  }

  /// **📌 Debounce search input for smooth filtering**
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = query.toLowerCase();
      notifyListeners();
    });
  }

  /// **📌 Pick an image for a specific user**
  Future<void> pickImage(String userId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedUserPhotos[userId] = picked.path;
      notifyListeners(); // 🔥 Notify UI
    }
  }

  /// **📌 Select/Deselect a user**
  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    notifyListeners(); // 🔥 Notify UI
  }

  /// **📌 Assign selected users as students**
  Future<void> assignStudents(BuildContext context) async {
    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      for (String userId in selectedUserIds) {
        String photoUrl = '';

        // **Upload photo if available**
        if (selectedUserPhotos.containsKey(userId)) {
          File imageFile = File(selectedUserPhotos[userId]!);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('student_photos')
              .child('$userId.jpg');
          await storageRef.putFile(imageFile);
          photoUrl = await storageRef.getDownloadURL();
        }

        // **Update Firestore user role to 'student'**
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'role': 'student',
          'photoUrl': photoUrl,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Users assigned as Students successfully!')),
      );

      // **Clear selections**
      selectedUserIds.clear();
      selectedUserPhotos.clear();

      notifyListeners();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
