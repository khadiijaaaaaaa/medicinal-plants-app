import 'package:flutter/material.dart';
import '../../repositories/user_repository.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../image_classification_widget.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is logged in (you might want to use shared_preferences for session)
    // For now, we'll just check if any users exist in the database
    final count = await _userRepository.getUserCount();
    setState(() {
      _isLoggedIn = count > 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn
        ? const ImageClassificationWidget()
        : AuthPage(onLoginSuccess: () {
      setState(() {
        _isLoggedIn = true;
      });
    });
  }
}

class AuthPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const AuthPage({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medicinal Plants'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login', icon: Icon(Icons.login)),
              Tab(text: 'Sign Up', icon: Icon(Icons.person_add)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoginPage(onLoginSuccess: onLoginSuccess),
            SignupPage(onSignupSuccess: onLoginSuccess),
          ],
        ),
      ),
    );
  }
}