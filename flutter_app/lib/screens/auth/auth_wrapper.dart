import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoading = true;
  bool _isLoggedIn = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId != null) {
        // Verify that the user exists in the database
        final userRepo = UserRepository();
        final user = await userRepo.getUserById(userId);
        
        if (mounted) {
          setState(() {
            _isLoggedIn = user != null;
            _userId = user?.userId;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
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

    return _isLoggedIn && _userId != null
        ? ImageClassificationWidget(userId: _userId!)
        : AuthPage(onLoginSuccess: (int userId) {
            setState(() {
              _isLoggedIn = true;
              _userId = userId;
            });
          });
  }
}

class AuthPage extends StatelessWidget {
  final void Function(int userId) onLoginSuccess;

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