import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_book/models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/grade_model.dart';
import '../../providers/class_management_provider.dart';
import '../../utils/snackbar_utils.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  // Separate state variables for each section
  String? _selectedGradeIdForCreate;
  String? _selectedTeacherId;
  String? _selectedGradeIdForAssign;
  String? _selectedClassId;
  String? _selectedStudentId;

  // Flags for operation-specific loading states
  bool _isCreatingClass = false;
  bool _isAssigningStudent = false;
  bool _isUnassigningStudent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassManagementProvider>(context, listen: false).fetchInitialData();
    });
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Class Management'),
            backgroundColor: Colors.blueAccent,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSectionHeader('Create a Class'),
                _buildCreateClassSection(provider),
                const SizedBox(height: 30),
                _buildSectionHeader('Assign/Unassign Students'),
                _buildAssignSection(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildCreateClassSection(ClassManagementProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter class name' : null,
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value: _selectedGradeIdForCreate,
              hint: 'Select a Grade',
              items: provider.grades.isNotEmpty
                  ? provider.grades.map((GradeModel grade) {
                return DropdownMenuItem(value: grade.id, child: Text(grade.gradeName));
              }).toList()
                  : [],
              onChanged: (val) {
                setState(() => _selectedGradeIdForCreate = val);
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value: _selectedTeacherId,
              hint: 'Select a Teacher',
              items: provider.teachers.isNotEmpty
                  ? provider.teachers.map((UserModel teacher) {
                return DropdownMenuItem(value: teacher.id, child: Text('${teacher.name} (${teacher.email})'));
              }).toList()
                  : [],
              onChanged: (val) {
                setState(() => _selectedTeacherId = val);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isCreatingClass
                  ? null
                  : () async {
                if (_formKey.currentState!.validate() &&
                    _selectedGradeIdForCreate != null &&
                    _selectedTeacherId != null) {
                  try {
                    setState(() => _isCreatingClass = true);
                    await provider.createClass(
                      className: _classNameController.text.trim(),
                      teacherId: _selectedTeacherId!,
                      gradeId: _selectedGradeIdForCreate!,
                    );
                    SnackbarUtils.showAutoDismissBanner(context, "Class created successfully", type: SnackbarType.success);

                    setState(() {
                      _selectedGradeIdForCreate = null;
                      _selectedTeacherId = null;
                    });
                    _classNameController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  } finally {
                    setState(() => _isCreatingClass = false);
                  }
                } else {
                  SnackbarUtils.showAutoDismissBanner(context, "Please complete all fields", type: SnackbarType.error);

                }
              },
              child: _isCreatingClass
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignSection(ClassManagementProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdown(
              value: _selectedGradeIdForAssign,
              hint: 'Select Grade for Assignment',
              items: provider.grades.isNotEmpty
                  ? provider.grades.map((GradeModel grade) {
                return DropdownMenuItem(value: grade.id, child: Text(grade.gradeName));
              }).toList()
                  : [],
              onChanged: (val) {
                setState(() {
                  _selectedGradeIdForAssign = val;
                  _selectedClassId = null; // Reset class selection when grade changes
                });
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value: _selectedClassId,
              hint: 'Select a Class',
              items: _selectedGradeIdForAssign != null && provider.classes.any((c) => c.gradeId == _selectedGradeIdForAssign)
                  ? provider.classes
                  .where((ClassModel c) => c.gradeId == _selectedGradeIdForAssign)
                  .map((ClassModel c) {
                return DropdownMenuItem(value: c.id, child: Text(c.className));
              }).toList()
                  : [],
              onChanged: (val) {
                setState(() => _selectedClassId = val);
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value: _selectedStudentId,
              hint: 'Select a Student',
              items: provider.students.isNotEmpty
                  ? provider.students.map((UserModel student) {
                return DropdownMenuItem(value: student.id, child: Text('${student.email}'));
              }).toList()
                  : [],
              onChanged: (val) {
                setState(() => _selectedStudentId = val);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAssigningStudent
                        ? null
                        : () async {
                      if (_selectedClassId != null &&
                          _selectedStudentId != null &&
                          _selectedGradeIdForAssign != null) {
                        try {
                          setState(() => _isAssigningStudent = true);
                          await provider.assignStudentToClass(
                            studentId: _selectedStudentId!,
                            classId: _selectedClassId!,
                            gradeId: _selectedGradeIdForAssign!,
                            studentEmail: provider.students
                                .firstWhere((student) => student.id == _selectedStudentId)
                                .email,
                          );
                          SnackbarUtils.showAutoDismissBanner(context, "Student assigned successfully", type: SnackbarType.success);

                        } catch (e) {

                          SnackbarUtils.showAutoDismissBanner(context, "Error: $e", type: SnackbarType.error);

                        } finally {
                          setState(() => _isAssigningStudent = false);
                        }
                      } else {
                        SnackbarUtils.showAutoDismissBanner(context, "Please select grade, class, and student", type: SnackbarType.warning);

                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: _isAssigningStudent
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Assign'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUnassigningStudent
                        ? null
                        : () async {
                      if (_selectedClassId != null && _selectedStudentId != null) {
                        try {
                          setState(() => _isUnassigningStudent = true);
                          await provider.unassignStudentFromClass(
                            studentId: _selectedStudentId!,
                            classId: _selectedClassId!,
                          );
                          SnackbarUtils.showAutoDismissBanner(context, "Student unassigned successfully", type: SnackbarType.success);

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() => _isUnassigningStudent = false);
                        }
                      } else {
                        SnackbarUtils.showAutoDismissBanner(context, "Please select class and student", type: SnackbarType.warning);


                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: _isUnassigningStudent
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Unassign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        items.isEmpty ? 'Not available' : hint,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      ),
      items: items,
      onChanged: items.isEmpty ? null : onChanged,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey, size: 28),
      isExpanded: true,
      dropdownColor: Colors.white,
      elevation: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (val) => val == null ? 'Please select an option' : null,
      menuMaxHeight: 300,
    );
  }
}