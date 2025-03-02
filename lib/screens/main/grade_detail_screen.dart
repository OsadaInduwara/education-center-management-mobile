import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';

class GradeDetailScreen extends StatefulWidget {
  final String gradeId;
  final String gradeName;

  const GradeDetailScreen({Key? key, required this.gradeId, required this.gradeName}) : super(key: key);

  @override
  State<GradeDetailScreen> createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends State<GradeDetailScreen> {
  List<Map<String, dynamic>> _classes = [];
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchClassesForGrade();
  }

  Future<void> _fetchClassesForGrade() async {
    setState(() => _isFetchingData = true);
    try {
      final classSnaps = await FirebaseFirestore.instance
          .collection('classes')
          .where('gradeId', isEqualTo: widget.gradeId)
          .get();

      final classes = classSnaps.docs.map((doc) => {
        'docId': doc.id,
        'className': doc['className'] ?? 'Unnamed Class',
        'classTeacherId': doc['classTeacherId'],  // Include the teacher ID here
        'gradeId': doc['gradeId'],

      }).toList();

      setState(() {
        _classes = classes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching classes: $e")));
    } finally {
      setState(() => _isFetchingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.gradeName,
          style: const TextStyle(color: AppColors.appBarText),
        ),
        backgroundColor: AppColors.appBarStart,
        centerTitle: true,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : _buildClassList(),
    );
  }

  Widget _buildClassList() {
    if (_classes.isEmpty) {
      return const Center(
          child: Text('No classes found for this grade.',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classData = _classes[index];
        return Card(
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.class_, color: AppColors.textPrimary),
            ),
            title: Text(
              classData['className'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary),
            onTap: () {
              Navigator.pushNamed(context, '/classdetail', arguments: classData);
            },
          ),
        );
      },
    );
  }
}
