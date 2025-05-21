import 'package:flutter/material.dart';
import '../services/data_importer.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            const Text(
              'Medicinal Plants',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF499265), // Deep Green
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color(0xFFBCE7B4), // Light Leaf
            ),
          ],
        ),
      ),
    );
  }
}