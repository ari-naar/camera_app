import 'package:flutter/material.dart';
import '../../navigation/navigation_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _shutterAnimation;
  late Animation<double> _flashAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _featureSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller (3 seconds)
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Content animation controller (800ms)
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation (0.0 -> 1.0 -> 0.5)
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.7),
      ),
    );

    // Logo rotation animation (0 -> 360)
    _logoRotateAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Shutter animation
    _shutterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Flash animation
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Content fade animation - delayed start
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Feature slide animation
    _featureSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _logoAnimationController.forward();
    setState(() => _showContent = true);
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Flash overlay
            if (_flashAnimation.value > 0)
              Positioned.fill(
                child: Opacity(
                  opacity: 1 - _flashAnimation.value,
                  child: Container(color: Colors.white),
                ),
              ),

            // Camera shutter
            Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Transform.rotate(
                angle: _logoRotateAnimation.value * 3.14159,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      HugeIcons.strokeRoundedCamera02,
                      color: Colors.white,
                      size: 48.sp,
                    ),
                  ),
                ),
              ),
            ),

            // Shutter animation
            if (_shutterAnimation.value > 0)
              Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(_shutterAnimation.value),
                      width: (1 - _shutterAnimation.value) * 20.w,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated logo with fade out
          if (_showContent)
            Positioned.fill(
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: Center(
                  child: _buildAnimatedLogo(),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Center(
                child: _buildAnimatedLogo(),
              ),
            ),

          // Content with fade in
          if (_showContent)
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 64.h),

                      // Welcome Text
                      SlideTransition(
                        position: _featureSlideAnimation,
                        child: Text(
                          'Welcome to\nCamera App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SlideTransition(
                        position: _featureSlideAnimation,
                        child: Text(
                          'A new way to capture and share your daily moments.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17.sp,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 64.h),

                      // Features List
                      ..._buildAnimatedFeatures(),

                      const Spacer(),

                      // Get Started Button
                      Padding(
                        padding: EdgeInsets.only(bottom: 32.h),
                        child: Column(
                          children: [
                            SlideTransition(
                              position: _featureSlideAnimation,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                      'hasCompletedOnboarding', true);
                                  if (mounted) {
                                    NavigationController.navigateToAuth(
                                        context);
                                  }
                                },
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
                            ),
                            SizedBox(height: 16.h),
                            SlideTransition(
                              position: _featureSlideAnimation,
                              child: Text(
                                'By continuing, you agree to our Terms & Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13.sp,
                                  height: 1.3,
                                  letterSpacing: -0.2,
                                ),
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
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedFeatures() {
    final features = [
      {
        'icon': HugeIcons.strokeRoundedImageAdd01,
        'title': 'Daily Photo Limit',
        'description': 'Take up to 5 photos each day, making every shot count.',
      },
      {
        'icon': HugeIcons.strokeRoundedSquareLock02,
        'title': 'Daily Reveal',
        'description':
            'Photos unlock at the end of each day, building excitement.',
      },
      {
        'icon': HugeIcons.strokeRoundedUserGroup,
        'title': 'Share with Friends',
        'description': 'Connect and share your daily moments with friends.',
      },
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;

      return Column(
        children: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.5, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _contentAnimationController,
                curve: Interval(
                  0.2 + (index * 0.1),
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
            ),
          ),
          SizedBox(height: 32.h),
        ],
      );
    }).toList();
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
