import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageGradesScreen extends StatefulWidget {
  const ManageGradesScreen({Key? key}) : super(key: key);

  @override
  State<ManageGradesScreen> createState() => _ManageGradesScreenState();
}

class _ManageGradesScreenState extends State<ManageGradesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gradeNameController = TextEditingController();

  bool _isLoading = false;
  String? _selectedGradeId; // Used for updating
  List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('grades').get();
      final grades = snapshot.docs.map((doc) {
        return {
          'gradeId': doc.id,
          'gradeName': doc['gradeName'],
        };
      }).toList();

      setState(() {
        _grades = grades;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching grades: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createOrUpdateGrade() async {
    if (!_formKey.currentState!.validate()) return;

    final gradeName = _gradeNameController.text.trim();
    setState(() => _isLoading = true);

    try {
      if (_selectedGradeId == null) {
        // Create new grade
        final docRef = await FirebaseFirestore.instance
            .collection('grades')
            .add({'gradeName': gradeName});
        // Optionally update the document with its own ID.
        await docRef.update({'gradeId': docRef.id});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Grade '$gradeName' created.")),
        );
      } else {
        // Update existing grade
        await FirebaseFirestore.instance
            .collection('grades')
            .doc(_selectedGradeId)
            .update({'gradeName': gradeName});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Grade updated to '$gradeName'.")),
        );
      }

      _gradeNameController.clear();
      _selectedGradeId = null;
      await _fetchGrades();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _deleteGrade(String gradeId) async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('grades').doc(gradeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grade deleted successfully.")),
      );
      await _fetchGrades();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting grade: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setGradeForEditing(String gradeId, String gradeName) {
    setState(() {
      _selectedGradeId = gradeId;
      _gradeNameController.text = gradeName;
    });
  }

  @override
  void dispose() {
    _gradeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Grades")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _gradeNameController,
                decoration: const InputDecoration(labelText: "Grade Name"),
                validator: (val) => val == null || val.isEmpty ? "Enter a grade name" : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _createOrUpdateGrade,
                  child: Text(_selectedGradeId == null ? "Create Grade" : "Update Grade"),
                ),
                if (_selectedGradeId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedGradeId = null;
                          _gradeNameController.clear();
                        });
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Existing Grades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _grades.isEmpty
                  ? const Center(child: Text("No grades found"))
                  : ListView.builder(
                itemCount: _grades.length,
                itemBuilder: (context, index) {
                  final grade = _grades[index];
                  return Card(
                    child: ListTile(
                      title: Text(grade['gradeName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _setGradeForEditing(grade['gradeId'], grade['gradeName']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGrade(grade['gradeId']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
