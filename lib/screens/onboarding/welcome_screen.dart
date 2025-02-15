import 'package:flutter/material.dart';
import '../../navigation/navigation_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 64.h),

                // Welcome Text
                Text(
                  'Welcome to\nCamera App',
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
                  'A new way to capture and share your daily moments.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17.sp,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 64.h),

                // Features List
                _buildFeatureItem(
                  icon: HugeIcons.strokeRoundedImageAdd01,
                  title: 'Daily Photo Limit',
                  description:
                      'Take up to 5 photos each day, making every shot count.',
                ),
                SizedBox(height: 32.h),
                _buildFeatureItem(
                  icon: HugeIcons.strokeRoundedSquareLock02,
                  title: 'Daily Reveal',
                  description:
                      'Photos unlock at the end of each day, building excitement.',
                ),
                SizedBox(height: 32.h),
                _buildFeatureItem(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  title: 'Share with Friends',
                  description:
                      'Connect and share your daily moments with friends.',
                ),

                const Spacer(),

                // Get Started Button
                Padding(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            NavigationController.navigateToAuth(context),
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
                          'Get Started',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13.sp,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            size: 22.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.sp,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
