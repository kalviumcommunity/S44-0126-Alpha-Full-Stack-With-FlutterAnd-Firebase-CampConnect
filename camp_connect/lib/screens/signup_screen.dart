import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth/auth_form_layout.dart';

import 'home_screen.dart';
import 'login_screen.dart';

// ================= SIGNUP =================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final user = await AuthService().signUp(
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
        const SnackBar(content: Text('Signup failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Create Account ✨',
      subtitle: 'Join CampConnect and explore campus events',

      emailController: emailCtrl,
      passwordController: passCtrl,

      buttonText: 'Create Account',
      onSubmit: _signup,

      footerText: 'Already have an account? ',
      footerActionText: 'Login',

      onFooterTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }
}
