import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';
import '../auth/auth_wrapper.dart'; // Update as needed

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthWrapper()),
    );
  }

  List<Widget> _buildPages() {
    return [
      OnboardingPage(
        icon: Icons.local_florist,
        title: 'Discover Plants',
        description:
        'Identify medicinal plants with a photo and get useful info.',
      ),
      OnboardingPage(
        icon: Icons.wifi_off,
        title: 'Works Offline',
        description:
        'Built for field use — no internet required to identify plants.',
      ),
      OnboardingPage(
        icon: Icons.warning,
        title: 'Stay Safe',
        description:
        'Get warnings if a plant is toxic or unsuitable for use.',
        isLast: true,
        onGetStarted: _completeOnboarding,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E7D3),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: _buildPages(),
      ),
    );
  }
}
