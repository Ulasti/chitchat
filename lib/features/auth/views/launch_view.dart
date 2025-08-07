import 'package:flutter/material.dart';
import 'package:lchat/features/auth/views/splash_view.dart';
import 'package:lchat/core/constants/app_colors.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SplashPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPrimary,
      body: Center(
        child: Image.asset(
          'assets/icons/chitchatlogo.png',
          width: 183,
          height: 165,
        ),
      ),
    );
  }
}
