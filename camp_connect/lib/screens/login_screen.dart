import 'package:camp_connect/screens/home_screen.dart';
import 'package:camp_connect/screens/signup_screen.dart';
import 'package:camp_connect/services/auth_service.dart';
import 'package:camp_connect/widgets/auth/auth_form_layout.dart';
import 'package:flutter/material.dart';

// ================= LOGIN =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final user = await AuthService().login(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Welcome Back 👋',
      subtitle: 'Login to continue to CampConnect',

      emailController: emailCtrl,
      passwordController: passCtrl,

      buttonText: 'Login',
      onSubmit: _login,

      footerText: 'New here? ',
      footerActionText: 'Create an account',

      onFooterTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        );
      },
    );
  }
}
