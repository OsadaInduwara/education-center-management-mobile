import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    final classSnaps = await FirebaseFirestore.instance
        .collection('classes')
        .where('gradeId', isEqualTo: widget.gradeId)
        .get();

    final classes = classSnaps.docs.map((doc) => {'docId': doc.id, 'className': doc['className'] ?? 'Unnamed Class'}).toList();

    setState(() {
      _classes = classes;
      _isFetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gradeName),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : _buildClassList(),
    );
  }

  Widget _buildClassList() {
    return _classes.isEmpty
        ? const Center(child: Text('No classes found for this grade.', style: TextStyle(fontSize: 18)))
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classData = _classes[index];
        return Card(
          color: Colors.purple.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.shade200,
              ),
              child: const Icon(Icons.class_, color: Colors.white),
            ),
            title: Text(
              classData['className'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.pushNamed(context, '/classDetail', arguments: classData);
            },
          ),
        );
      },
    );
  }
}
