import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isClicked = false;

  void toggleText() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampConnect')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isClicked ? 'Let’s Get Started 🚀' : 'Welcome to CampusConnect',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.school, size: 80, color: Colors.indigo),
            const SizedBox(height: 30),
            PrimaryButton(text: 'Click Me', onPressed: toggleText),
          ],
        ),
      ),
    );
  }
}
