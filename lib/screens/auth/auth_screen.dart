import 'package:flutter/material.dart';
import '../../navigation/navigation_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual authentication
      NavigationController.navigateToHome(context);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70, size: 20.sp),
      labelStyle: TextStyle(
        color: Colors.white70,
        fontSize: 17.sp,
        letterSpacing: -0.3,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
      ),
      errorStyle: TextStyle(
        color: Colors.red.withOpacity(0.7),
        fontSize: 13.sp,
        letterSpacing: -0.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 64.h),

                    // Title
                    Text(
                      _isLogin ? 'Welcome\nBack' : 'Create\nAccount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _isLogin
                          ? 'Sign in to continue capturing moments.'
                          : 'Start your journey with us today.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17.sp,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // Form Fields
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          letterSpacing: -0.3,
                        ),
                        decoration: _buildInputDecoration(
                          'Username',
                          HugeIcons.strokeRoundedUserAdd01,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],

                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        letterSpacing: -0.3,
                      ),
                      decoration: _buildInputDecoration(
                        'Email',
                        HugeIcons.strokeRoundedMail01,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        letterSpacing: -0.3,
                      ),
                      obscureText: true,
                      decoration: _buildInputDecoration(
                        'Password',
                        HugeIcons.strokeRoundedSquareLock02,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        _isLogin ? 'Sign In' : 'Create Account',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Toggle Mode Button
                    Center(
                      child: TextButton(
                        onPressed: _toggleMode,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Create one'
                              : 'Already have an account? Sign in',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
                            letterSpacing: -0.3,
                          ),
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
    );
  }
}
