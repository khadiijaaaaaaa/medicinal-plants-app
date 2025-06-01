import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;
  final VoidCallback? onGetStarted;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
    this.onGetStarted, required String subText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Color(0xFF499265)),
          SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF499265),
            ),
          ),
          SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          if (isLast)
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF499265),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text('Get Started',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
