import 'package:flutter/material.dart';
import 'package:lucy_app/screens/login_screen.dart';
import 'package:lucy_app/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUCY App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundStart, // Updated from AppColors.background
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light, // Updated to light theme
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
