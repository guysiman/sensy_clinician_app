import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isButtonEnabled = false;
  bool _emailShowError = false;
  bool _passwordShowError = false;

  String? errorMessage = '';
  String? _emailError;
  String? _passwordError;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _usernameController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        debugPrint(e.code);
        switch (e.code) {
          case 'invalid-email':
          case 'invalid-credential':
          case 'wrong-password':
          case 'user-not-found':
            errorMessage = "Invalid credentials";
            break;
          case 'network-request-failed':
            errorMessage = "Please check your internet connection";
            break;
          default:
            errorMessage = "An unexpected error occurred";
        }
      });
      if (errorMessage != null && errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailShowError = true);
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) setState(() => _passwordShowError = true);
    });
  }

  void _checkFields() {
    setState(() {
      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_usernameController.text)) {
        _emailError = 'Enter a valid email';
      } else {
        _emailError = null;
      }
      // Password validation
      if (_passwordController.text.length < 7) {
        _passwordError = 'Password must be at least 7 characters';
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(_passwordController.text)) {
        _passwordError = 'Password must contain letters and numbers';
      } else {
        _passwordError = null;
      }
      _isButtonEnabled = _emailError == null && _passwordError == null &&
        _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    if (!username.contains('@')) {
      setState(() {
        errorMessage = 'Not a valid email';
      });
    } else if (password.length < 6) {
      setState(() {
        errorMessage = 'Password not long enough';
      });
    } else {
      signInWithEmailAndPassword();
    }
  }

  void _onForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  }

  void _onSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 388,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text('Sign in',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 40),

                  // Username field
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Username',
                          style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _usernameController,
                    focusNode: _emailFocus,
                    decoration: InputDecoration(
                      labelText: 'Enter your username',
                      labelStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: Color(
                                0xFFE8EDEC)), // Border color when not focused
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _emailShowError ? _emailError : null,
                    ),
                    onChanged: (_) {
                      if (_emailShowError) setState(() => _emailShowError = false);
                      _checkFields();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password',
                          style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      labelStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: Color(
                                0xFFE8EDEC)), // Border color when not focused
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _passwordShowError ? _passwordError : null,
                    ),
                    onChanged: (_) {
                      if (_passwordShowError) setState(() => _passwordShowError = false);
                      _checkFields();
                    },
                  ),

                  const SizedBox(height: 8),

                  // Forgot password link
                  TextButton(
                    onPressed: _onForgotPassword,
                    child: Text('Forgot password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                  ),

                  const SizedBox(height: 40),

                  const SizedBox(height: 40),

                  // Enter account button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((255 * 0.5).toInt()), // Background Color
                        disabledForegroundColor: Colors.white70, //Text Color
                      ),
                      onPressed: _isButtonEnabled
                          ? () {
                              _onSignIn();
                            }
                          : null,
                      child: const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Sign up prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      GestureDetector(
                        onTap: _onSignUp,
                        child: Text(
                          'Sign up',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
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
