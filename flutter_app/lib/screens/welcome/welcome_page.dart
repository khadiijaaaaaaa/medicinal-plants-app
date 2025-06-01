import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../image_classification_widget.dart';
import '../onboarding/onboarding_screen.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    final userId = prefs.getInt('userId') ?? 0;

    if (onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ImageClassificationWidget(userId: userId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E7D3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 100, color: Color(0xFF499265)),
            SizedBox(height: 16),
            Text(
              'plantsapp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF499265),
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBCE7B4)),
            ),
          ],
        ),
      ),
    );
  }
}
