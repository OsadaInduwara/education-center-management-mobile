import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({Key? key}) : super(key: key);

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Teacher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Teacher Name'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter name' : null,
              ),
              // Mobile
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile'),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter mobile' : null,
              ),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter email' : null,
              ),
              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),

              // Photo Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectedImageFile == null
                      ? const Text('No image selected')
                      : Image.file(
                    _selectedImageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: const Text('Pick Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _registerTeacher,
                child: const Text('Register Teacher'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
      });
    }
  }

  Future<void> _registerTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final age = _ageController.text.trim();

    try {
      // 1) Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('teacher_photos')
          .child('$email.jpg'); // or use a random ID
      await storageRef.putFile(_selectedImageFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      // 2) Create user in Firebase Auth
      // Usually you'd let manager set a password or generate one
      // For example, default password = '123456' (not recommended for production)
      final defaultPassword = '123456';
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: defaultPassword);

      final uid = userCred.user!.uid;

      // 3) Store additional student info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'mobile': mobile,
        'email': email,
        'age': age,
        'photoUrl': downloadUrl,
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher registered successfully!')),
      );

      // Clear inputs
      _nameController.clear();
      _mobileController.clear();
      _emailController.clear();
      _ageController.clear();
      setState(() {
        _selectedImageFile = null;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
