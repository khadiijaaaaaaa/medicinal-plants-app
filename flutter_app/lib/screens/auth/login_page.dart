import 'package:flutter/material.dart';
import 'package:flutter_app/screens/auth/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repositories/user_repository.dart';

class LoginPage extends StatefulWidget {
  final void Function(int userId) onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userRepo = UserRepository();
      final user = await userRepo.getUserByEmail(_emailController.text.trim());

      if (user == null || user.passwordHash != _passwordController.text) {
        setState(() {
          _errorMessage = 'Invalid email or password';
          _isLoading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.userId!);
      widget.onLoginSuccess(user.userId!);
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7D3), // Soft Beige
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Leaf Icon
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.eco, size: 100, color: Color(0xFF499265)), // Deep Green
                ),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFFAF8447)), // Earthy Brown
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFFD9B17D)), // Sandy Brown
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF499265)), // Deep Green
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your email' : null,
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFFAF8447)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFFD9B17D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF499265)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 30),

                // Login Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF499265), // Deep Green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign Up Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupPage(onSignupSuccess: widget.onLoginSuccess),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF87CB7C), // Fresh Leaf
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
