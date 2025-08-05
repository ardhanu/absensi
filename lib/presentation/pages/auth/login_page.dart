import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:attendify/presentation/pages/auth/register_page.dart';
import 'package:attendify/presentation/pages/home/home_page.dart';
import 'package:attendify/data/local/preferences.dart';
import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/button.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isVisiblePassword = true;

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      print('DEBUG: Starting login process...');
      print('DEBUG: Email: ${_emailController.text.trim()}');
      print('DEBUG: Password length: ${_passwordController.text.length}');

      // Clear any existing session before login
      await Preferences.clearSession();
      print('DEBUG: Cleared existing session');

      AuthResponse result;

      try {
        // Use the new AuthService
        print('DEBUG: Attempting login with new AuthService...');
        result = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        print('DEBUG: Login successful');
      } catch (e) {
        print('DEBUG: Login failed: $e');
        throw e;
      }

      print('DEBUG: Login result: ${result.message}');
      print('DEBUG: User: ${result.user.name}');
      print('DEBUG: Token: ${result.token}');

      // Validate the response
      if (result.token.isEmpty) {
        throw Exception('Invalid token received from server');
      }

      if (result.user.name.isEmpty || result.user.email.isEmpty) {
        throw Exception('Invalid user data received from server');
      }

      await Preferences.saveLoginSession();

      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print('DEBUG: Login error: $e');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/logo/attendify_black.png',
                              height: 150,
                              width: 150,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Login into your account',
                              style: GoogleFonts.lexend(fontSize: 14),
                            ),
                          ),
                          SizedBox(height: 28),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'Email',
                                hintStyle: GoogleFonts.lexend(fontSize: 14),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: isVisiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock_outlined),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.lexend(fontSize: 14),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isVisiblePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isVisiblePassword = !isVisiblePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 34),
                          CustomButton(
                            onPressed: _handleLogin,
                            text: 'LOGIN',
                            textStyle: GoogleFonts.lexend(),
                            backgroundColor: AppColors.primary,
                            height: 54,
                          ),
                          SizedBox(height: 34),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade300,
                                  endIndent: 12,
                                ),
                              ),
                              Text(
                                'Or sign in with',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade300,
                                  indent: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google login button
                              InkWell(
                                onTap: () {
                                  // TODO: Implement Google login
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/google.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // WhatsApp login button
                              InkWell(
                                onTap: () {
                                  // TODO: Implement WhatsApp login
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/whatsapp.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'WhatsApp',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 26.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have account? ",
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tambahkan copyright di bawah konten utama
                          const SizedBox(height: 24),
                          CopyrightText(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
