import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grade_provider.dart';

class ManageGradesScreen extends StatefulWidget {
  const ManageGradesScreen({Key? key}) : super(key: key);

  @override
  State<ManageGradesScreen> createState() => _ManageGradesScreenState();
}

class _ManageGradesScreenState extends State<ManageGradesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gradeNameController = TextEditingController();
  String? _selectedGradeId; // Stores grade ID for update mode
  bool _isProcessing = false; // UI state

  /// **📌 Handles Grade Creation & Update**
  Future<void> _createOrUpdateGrade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    final gradeProvider = Provider.of<GradesProvider>(context, listen: false);

    try {
      await gradeProvider.createOrUpdateGrade(
        gradeId: _selectedGradeId,
        gradeName: _gradeNameController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedGradeId == null ? "Grade Created" : "Grade Updated")),
      );
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// **📌 Delete a Grade**
  Future<void> _deleteGrade(String gradeId) async {
    setState(() => _isProcessing = true);
    final gradeProvider = Provider.of<GradesProvider>(context, listen: false);

    try {
      await gradeProvider.deleteGrade(gradeId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grade Deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting grade: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// **📌 Set Grade for Editing**
  void _setGradeForEditing(String gradeId, String gradeName) {
    setState(() {
      _selectedGradeId = gradeId;
      _gradeNameController.text = gradeName;
    });
  }

  /// **📌 Reset Form After Submission**
  void _resetForm() {
    setState(() {
      _selectedGradeId = null;
      _gradeNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Grades")),
      body: Padding(
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

            // **Action Buttons**
            Row(
              children: [
                ElevatedButton(
                  onPressed: _createOrUpdateGrade,
                  child: _isProcessing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_selectedGradeId == null ? "Create Grade" : "Update Grade"),
                ),
                if (_selectedGradeId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextButton(
                      onPressed: _resetForm,
                      child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Existing Grades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // **StreamBuilder for Real-time Grade Updates**
            Expanded(
              child: Consumer<GradesProvider>(
                builder: (context, gradesProvider, _) {
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: gradesProvider.gradesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final grades = snapshot.data ?? [];

                      if (grades.isEmpty) {
                        return const Center(child: Text("No grades found"));
                      }

                      return ListView.builder(
                        itemCount: grades.length,
                        itemBuilder: (context, index) {
                          final grade = grades[index];
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
                      );
                    },
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
