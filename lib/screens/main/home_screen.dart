import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
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
    final userName = userProvider.currentUser?.name ?? 'User';

    if (userProvider.currentUser == null && !isLoadingUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: [
              // 1) Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/appbar_bg.jpg'), // Your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 2) Gradient overlay (optional for better text/icon contrast)
              Container(

                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.appBarStart.withOpacity(0.5),
                      AppColors.appBarEnd.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                  ),
                ),


              ),
              // 3) The content (row with avatar, name, icons) pinned to the bottom
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/profile_placeholder.jpg'),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome,',
                                  style: TextStyle(fontSize: 14, color: AppColors.appBarText),
                                ),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.appBarText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person, color: AppColors.appBarIcon),
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppColors.appBarIcon),
                              onPressed: () async {
                                await userProvider.signOut();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/managerPanel');
              },
              child: const Text(
                'Go to Manager Control Panel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Expanded(child: _buildGradeList()),
      ],
    );
  }

  Widget _buildGradeList() {
    return _grades.isEmpty
        ? const Center(child: Text('No grades found.', style: TextStyle(fontSize: 18, color: AppColors.textPrimary)))
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final grade = _grades[index];
        return Card(
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 10,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.menu_book_sharp, color: Colors.white),
            ),
            title: Text(
              grade['gradeName'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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

extension on User? {
  get name => null;
}
