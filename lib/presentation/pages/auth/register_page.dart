import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/presentation/pages/auth/login_page.dart';
import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/button.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;

  bool isVisiblePassword = true;
  bool isVisibleConfirmPassword = true;

  final List<Map<String, String>> _genderOptions = [
    {'label': 'Male', 'value': 'L'},
    {'label': 'Female', 'value': 'P'},
  ];

  String? _genderErrorText;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRegister() async {
    if (!((_formKey.currentState?.validate() ?? false) && _validateGender()))
      return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final result = await AuthService.register(
        name: _usernameController.text,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        jenisKelamin: _selectedGender ?? '',
      );
      print('Registration result: ${result.message}');
      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  bool _validateGender() {
    if (_selectedGender == null) {
      setState(() => _genderErrorText = 'Please select your gender');
      return false;
    } else {
      setState(() => _genderErrorText = null);
      return true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/logo/attendify_black.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create your account',
                    style: GoogleFonts.lexend(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _usernameController,
                  Icons.person_outline,
                  'Username',
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your username'
                      : val.length < 3
                      ? 'Username must be at least 3 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  Icons.email_outlined,
                  'Email',
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your email'
                      : !val.contains('@')
                      ? 'Please enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  _passwordController,
                  'Password',
                  isVisiblePassword,
                  () => setState(() => isVisiblePassword = !isVisiblePassword),
                  (val) => val == null || val.isEmpty
                      ? 'Please enter your password'
                      : val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  _confirmPasswordController,
                  'Confirm Password',
                  isVisibleConfirmPassword,
                  () => setState(
                    () => isVisibleConfirmPassword = !isVisibleConfirmPassword,
                  ),
                  (val) => val != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildGenderSelection(),
                const SizedBox(height: 34),
                CustomButton(
                  onPressed: _handleRegister,
                  text: 'REGISTER',
                  textStyle: GoogleFonts.lexend(),
                  backgroundColor: AppColors.primary,
                  height: 54,
                ),
                // Tambahkan copyright di bawah konten utama
                const SizedBox(height: 24),
                CopyrightText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText,
    String? Function(String?)? validator,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          hintStyle: GoogleFonts.lexend(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hintText,
    bool isVisible,
    VoidCallback toggle,
    String? Function(String?)? validator,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isVisible,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outlined),
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          hintStyle: GoogleFonts.lexend(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: _genderOptions
                .map(
                  (option) => Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option['value'] ?? 'Not Choosen',
                          groupValue: _selectedGender,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() {
                            _selectedGender = val;
                            _genderErrorText = null;
                          }),
                        ),
                        if (option['value'] == 'L')
                          const Icon(Icons.male, color: Colors.blue, size: 20)
                        else if (option['value'] == 'P')
                          const Icon(
                            Icons.female,
                            color: Colors.pink,
                            size: 20,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          option['label']!,
                          style: GoogleFonts.lexend(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (_genderErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _genderErrorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        labelStyle: GoogleFonts.lexend(fontSize: 14, color: Colors.grey[800]),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                display(item),
                style: GoogleFonts.lexend(fontSize: 14),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }
}
