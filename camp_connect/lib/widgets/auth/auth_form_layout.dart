import 'package:flutter/material.dart';

import 'auth_input_field.dart';

// ================= AUTH FORM LAYOUT =================

class AuthFormLayout extends StatelessWidget {
  final String title;
  final String subtitle;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final String buttonText;

  final VoidCallback onSubmit;

  final String footerText;
  final String footerActionText;
  final VoidCallback onFooterTap;

  const AuthFormLayout({
    super.key,
    required this.title,
    required this.subtitle,

    required this.emailController,
    required this.passwordController,

    required this.buttonText,
    required this.onSubmit,

    required this.footerText,
    required this.footerActionText,
    required this.onFooterTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: size.height * 0.07),

                  // ================= HEADER =================
                  Text(
                    title,

                    style: TextStyle(
                      fontSize: isSmall ? 24 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= EMAIL =================
                  AuthInputField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // ================= PASSWORD =================
                  AuthInputField(
                    controller: passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 28),

                  // ================= BUTTON =================
                  Center(
                    child: SizedBox(
                      width: size.width > 420 ? 320 : double.infinity,
                      height: 52,

                      child: ElevatedButton(
                        onPressed: onSubmit,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),

                        child: Text(
                          buttonText,

                          style: const TextStyle(
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
                      onPressed: onFooterTap,

                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),

                          children: [
                            TextSpan(
                              text: footerText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            TextSpan(
                              text: footerActionText,

                              style: const TextStyle(
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
