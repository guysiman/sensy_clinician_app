import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_in_page.dart'; // Import the SignInPage

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _firstNameFocus = FocusNode();
  FocusNode _lastNameFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _errorMessage = '';
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  bool _firstNameShowError = false;
  bool _lastNameShowError = false;
  bool _emailShowError = false;
  bool _passwordShowError = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _firstNameFocus.addListener(() {
      if (!_firstNameFocus.hasFocus) setState(() => _firstNameShowError = true);
    });
    _lastNameFocus.addListener(() {
      if (!_lastNameFocus.hasFocus) setState(() => _lastNameShowError = true);
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailShowError = true);
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) setState(() => _passwordShowError = true);
    });
  }

  void _checkFields() {
    setState(() {
      // First Name validation
      if (_firstNameController.text.length < 2) {
        _firstNameError = 'First name must be at least 2 characters';
      } else if (RegExp(r'^[0-9]').hasMatch(_firstNameController.text)) {
        _firstNameError = 'First name cannot start with a number';
      } else {
        _firstNameError = null;
      }
      // Last Name validation
      if (_lastNameController.text.length < 2) {
        _lastNameError = 'Last name must be at least 2 characters';
      } else if (RegExp(r'^[0-9]').hasMatch(_lastNameController.text)) {
        _lastNameError = 'Last name cannot start with a number';
      } else {
        _lastNameError = null;
      }
      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
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
      _isButtonEnabled = _firstNameError == null && _lastNameError == null && _emailError == null && _passwordError == null &&
        _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Not a valid email';
      });
      if (_errorMessage != null && _errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password not long enough';
      });
      if (_errorMessage != null && _errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    } else if (_firstNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter first name';
      });
      if (_errorMessage != null && _errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    } else if (_lastNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter last name';
      });
      if (_errorMessage != null && _errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user!.updateDisplayName(
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );
      await userCredential.user!.sendEmailVerification();
      // Show toast/snackbar and redirect to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                'A verification email has been sent. Please verify your email before logging in.',
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInPage()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      if (_errorMessage != null && _errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: const Color(0xFFF8F8F8), // off white
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                  Text('Sign up', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 40),
                  // First Name
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('First Name', style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    decoration: InputDecoration(
                      labelText: 'Enter your first name',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _firstNameShowError ? _firstNameError : null,
                    ),
                    onChanged: (_) {
                      if (_firstNameShowError) setState(() => _firstNameShowError = false);
                      _checkFields();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Last Name
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Last Name', style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    decoration: InputDecoration(
                      labelText: 'Enter your last name',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _lastNameShowError ? _lastNameError : null,
                    ),
                    onChanged: (_) {
                      if (_lastNameShowError) setState(() => _lastNameShowError = false);
                      _checkFields();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email', style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
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
                  // Password
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password', style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE8EDEC))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _passwordShowError ? _passwordError : null,
                    ),
                    onChanged: (_) {
                      if (_passwordShowError) setState(() => _passwordShowError = false);
                      _checkFields();
                    },
                  ),
                  const SizedBox(height: 40),
                  if (_errorMessage != null && _errorMessage != '') Text('$_errorMessage'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((255 * 0.5).toInt()),
                        disabledForegroundColor: Colors.white70,
                      ),
                      onPressed: _isButtonEnabled && !_isLoading ? _signUp : null,
                      child: _isLoading ? const CircularProgressIndicator() : const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Sign in',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
