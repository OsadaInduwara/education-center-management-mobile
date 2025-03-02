import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userDoc;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userDoc => _userDoc;

  // e.g. 'manager' or 'student'
  String? get role => _userDoc?['role'];

  UserProvider() {
    // Listen to FirebaseAuth changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;

    if (user == null) {
      _userDoc = null;
      notifyListeners();
      return;
    }

    await _fetchUserDoc(user.uid);
  }

  Future<void> _fetchUserDoc(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userDoc = doc.data();
      } else {
        _userDoc = null;
      }
    } catch (e) {
      _userDoc = null;
      debugPrint('Error fetching user doc: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs in with email & password (replaces AuthService)
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // onAuthStateChanged will then fetch Firestore doc
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out
  Future<void> signOut() async {
    await _auth.signOut();
    // onAuthStateChanged will set _currentUser to null
  }
}
