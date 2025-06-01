import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';
import '../auth/auth_wrapper.dart';

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
        description: 'Identify medicinal plants with a photo and get useful info.',
        subText: 'Snap a photo and let the app identify the plant instantly.',
      ),
      OnboardingPage(
        icon: Icons.wifi_off,
        title: 'Works Offline',
        description: 'Built for field use — no internet required to identify plants.',
        subText: 'Perfect for nature walks or remote locations.',
      ),
      OnboardingPage(
        icon: Icons.warning,
        title: 'Stay Safe',
        description: 'Get warnings if a plant is toxic or unsuitable for use.',
        subText: 'Always be aware of toxic plants around you.',
        isLast: true,
        onGetStarted: _completeOnboarding,
      ),
    ];
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF499265) : Colors.grey[300],
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List.generate(
      _buildPages().length,
          (index) => _buildIndicator(index == _currentPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: _buildPages(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
