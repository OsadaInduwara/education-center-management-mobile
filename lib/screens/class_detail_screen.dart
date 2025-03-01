import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class ClassDetailScreen extends StatefulWidget {
  // Requires classData to be passed.
  final Map<String, dynamic> classData;

  const ClassDetailScreen({Key? key, required this.classData})
      : super(key: key);

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  Map<String, dynamic>? teacherData;
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  Future<void> _fetchClassDetails() async {
    setState(() => isLoading = true);
    try {
      // Use the class document's id from widget.classData.
      final String? classId = widget.classData['docId'];

      if (classId == null) {
        throw Exception("Class ID is missing");
      }
      // 1. Fetch teacher details using classTeacherId.
      final String? teacherId = widget.classData['classTeacherId'];

      if (teacherId != null) {
        final teacherDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(teacherId)
            .get();
        if (teacherDoc.exists) {
          teacherData = teacherDoc.data();
        }
      }
      // 2. Fetch enrolled students.
      final QuerySnapshot studentSnap = await FirebaseFirestore.instance
          .collection('enrolments')
          .where('classIds', arrayContains: classId)
          .get();
      students = studentSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint("Error fetching class details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String className = widget.classData['className'] ?? 'Unnamed Class';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Class Detail: $className",
            style: const TextStyle(color: AppColors.appBarText)),
        backgroundColor: AppColors.appBarStart,
        iconTheme: const IconThemeData(color: AppColors.appBarIcon),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Class Name.
            Text(
              "Class: $className",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            // Display Teacher Information.
            teacherData != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Teacher:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text("Name: ${teacherData!['name'] ?? 'N/A'}",
                    style: const TextStyle(color: AppColors.textPrimary)),
                Text("Email: ${teacherData!['email'] ?? 'N/A'}",
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            )
                : const Text("Teacher information not available",
                style: TextStyle(color: AppColors.textPrimary)),
            const Divider(color: AppColors.secondary, height: 30),
            // Display count and list of enrolled students.
            Text(
              "Enrolled Students: ${students.length}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            students.isEmpty
                ? const Text("No students enrolled.",
                style: TextStyle(color: AppColors.textPrimary))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(
                      "${student['name']} (${student['email']})",
                      style: const TextStyle(color: AppColors.textPrimary)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
