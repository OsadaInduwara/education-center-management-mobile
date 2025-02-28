import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'grade_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _grades = [];
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() => _isFetchingData = true);

    final gradeSnaps = await FirebaseFirestore.instance.collection('grades').get();
    final grades = gradeSnaps.docs.map((doc) => {
      'docId': doc.id,
      'gradeName': doc['gradeName'] ?? 'Unnamed Grade',
    }).toList();

    setState(() {
      _grades = grades;
      _isFetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoadingUser = userProvider.isLoading;
    final role = userProvider.role;

    if (userProvider.currentUser == null && !isLoadingUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Education Center", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userProvider.signOut();
            },
          ),
        ],
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(role),
    );
  }

  Widget _buildContent(String? role) {
    return Column(
      children: [
        if (role == 'manager')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/managerPanel');
              },
              child: const Text('Go to Manager Control Panel', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        const SizedBox(height: 10),
        Expanded(child: _buildGradeList()),
      ],
    );
  }

  Widget _buildGradeList() {
    return _grades.isEmpty
        ? const Center(child: Text('No grades found.', style: TextStyle(fontSize: 18)))
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final grade = _grades[index];
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
              child: const Icon(Icons.school, color: Colors.white),
            ),
            title: Text(
              grade['gradeName'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GradeDetailScreen(
                    gradeId: grade['docId'],
                    gradeName: grade['gradeName'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
