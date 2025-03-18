import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:student_book/providers/assign_student_provider.dart';
import 'package:student_book/providers/assign_teacher_provider.dart';
import 'package:student_book/providers/attendance_provider.dart';
import 'package:student_book/providers/class_management_provider.dart';
import 'package:student_book/providers/grade_provider.dart';
import 'package:student_book/screens/auth/auth_wrapper.dart';
import 'package:student_book/screens/auth/register_screen.dart';
import 'package:student_book/screens/auth/subscription_screen.dart';
import 'package:student_book/screens/main/class_detail_screen.dart';
import 'package:student_book/screens/main/home_screen.dart';
import 'package:student_book/screens/main/manager_control_panel.dart';
import 'package:student_book/screens/manager/assign_student_screen.dart';
import 'package:student_book/screens/manager/assign_teacher_screen.dart';
import 'package:student_book/screens/manager/attendance_screen.dart';
import 'package:student_book/screens/main/profile_screen.dart';
import 'package:student_book/screens/manager/class_management_screen.dart';
import 'package:student_book/screens/manager/manage_grades_screens.dart';
import 'package:student_book/providers/user_provider.dart';
import 'package:student_book/screens/student/studentdashboard.dart';
import 'package:student_book/screens/teacher/teacherdashboard.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GradesProvider>(
          create: (_) => GradesProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<ClassManagementProvider>(
          create: (_) => ClassManagementProvider(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(),
        ),
        ChangeNotifierProvider<TeacherProvider>(
          create: (_) => TeacherProvider(),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (_) => StudentProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'My Institute App',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/managerPanel': (context) => const ManagerControlPanel(),
          '/classManagement': (context) => const ClassManagementScreen(),
          '/assignStudent': (context) => const AssignStudentScreen(),
          '/assignTeacher': (context) => const AssignTeacherScreen(),
          '/attendance': (context) => const MarkAttendanceScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/managegrade': (context) => const ManageGradesScreen(),
          '/classdetail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ClassDetailScreen(classData: args);
          },
          '/subscrition': (context) => SubscriptionPage(),
          '/teacherdashboard': (context) => const TeacherDashboardScreen(),
          '/studentdashboard': (context) => const StudentDashboardScreen(),




        },
      ),
    );
  }
}
