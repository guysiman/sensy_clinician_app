import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  String? _emailError;
  bool _emailShowError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailShowError = true);
    });
  }

  void _validateEmail() {
    setState(() {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
        _emailError = 'Enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    setState(() { _isLoading = true; });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: double.infinity,
              child: Text(
                'Password reset email sent. Please check your inbox.',
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
        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            width: double.infinity,
            child: Text(
              e.message ?? 'Failed to send reset email',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: const Color(0xFFF8F8F8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
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
                  Text('Forgot Password', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 40),
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
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE8EDEC)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _emailShowError ? _emailError : null,
                    ),
                    onChanged: (_) {
                      if (_emailShowError) setState(() => _emailShowError = false);
                      _validateEmail();
                    },
                  ),
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
                      onPressed: _emailError == null && _emailController.text.isNotEmpty && !_isLoading
                          ? _sendResetEmail
                          : null,
                      child: _isLoading ? const CircularProgressIndicator() : const Text('Send Reset Email'),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Back to Login',
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
