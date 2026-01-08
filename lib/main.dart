import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database; // Initialize database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CookBook',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xffff565f),
      ),
      home: const LoginPage(),
    );
  }
}
