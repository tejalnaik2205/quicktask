import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/back4app_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Back4AppService.initialize(); // Ensure Parse SDK is initialized before running the app

  runApp(const QuickTaskApp());
}

class QuickTaskApp extends StatelessWidget {
  const QuickTaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
