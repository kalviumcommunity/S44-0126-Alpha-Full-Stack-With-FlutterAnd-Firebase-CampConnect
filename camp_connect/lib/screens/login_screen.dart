import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'home_screen.dart';
import 'signup_screen.dart';

// ================= LOGIN SCREEN =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ================= CONTROLLERS =================

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // ================= LIFECYCLE =================

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();

    super.dispose();
  }

  // ================= INPUT UI =================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  // ================= LOGIN =================

  Future<void> _handleLogin(BuildContext context) async {
    final user = await AuthService().login(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    if (!context.mounted) return;

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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    // ================= LAYOUT =================

    final size = MediaQuery.of(context).size;

    final bool isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // ================= BODY =================
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: size.height * 0.08),

                  // ================= HEADER =================
                  Text(
                    'Welcome Back 👋',

                    style: TextStyle(
                      fontSize: isSmall ? 24 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Login to continue to CampConnect',

                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= EMAIL =================
                  TextField(
                    controller: emailCtrl,

                    keyboardType: TextInputType.emailAddress,

                    decoration: _inputDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= PASSWORD =================
                  TextField(
                    controller: passCtrl,

                    obscureText: true,

                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= LOGIN BUTTON =================
                  Center(
                    child: SizedBox(
                      width: size.width > 420 ? 320 : double.infinity,

                      height: 52,

                      child: ElevatedButton(
                        onPressed: () => _handleLogin(context),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),

                        child: const Text(
                          'Login',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= FOOTER =================
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },

                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),

                          children: const [
                            TextSpan(
                              text: 'New here? ',

                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: 'Create an account',

                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
