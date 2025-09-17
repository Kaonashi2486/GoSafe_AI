import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hacknova/view/SignIn.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with gradient overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/map_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo/Title Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Join NavRakshak',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your safety account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Register Form Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Username Field
                                _buildInputField(
                                  controller: _usernameController,
                                  placeholder: 'Username',
                                  icon: CupertinoIcons.person,
                                ),
                                const SizedBox(height: 16),

                                // Email Field
                                _buildInputField(
                                  controller: _emailController,
                                  placeholder: 'Email Address',
                                  icon: CupertinoIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                _buildPasswordField(),
                                const SizedBox(height: 24),

                                // Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    borderRadius: BorderRadius.circular(16),
                                    color: const Color(
                                      0xFF34C759,
                                    ), // Green color for register
                                    onPressed: _isLoading ? null : _register,
                                    child:
                                        _isLoading
                                            ? const CupertinoActivityIndicator(
                                              color: Colors.white,
                                            )
                                            : const Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF007AFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const SignInPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Terms and Privacy (Optional)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'By creating an account, you agree to our Terms of Service and Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        placeholderStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, color: Colors.grey[500], size: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: CupertinoTextField(
        controller: _passwordController,
        placeholder: 'Password (min. 6 characters)',
        placeholderStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        obscureText: _obscurePassword,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(CupertinoIcons.lock, color: Colors.grey[500], size: 20),
        ),
        suffix: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Enhanced validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (username.length < 3) {
      _showErrorDialog('Username must be at least 3 characters long');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false;
    });

    // Show success and navigate to sign in
    _showSuccessDialog();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text(
              'Account Created!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF34C759),
              ),
            ),
            content: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Your account has been created successfully. You can now sign in.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}
