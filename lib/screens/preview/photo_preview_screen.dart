import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final XFile photo;

  const PhotoPreviewScreen({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _topWhiteController;
  late AnimationController _bottomBlackController;
  late AnimationController _notchBlackController;
  late AnimationController _photoContainerController;
  late AnimationController _textController;

  late Animation<double> _topWhiteAnimation;
  late Animation<double> _bottomBlackAnimation;
  late Animation<double> _notchBlackSlideAnimation;
  late Animation<double> _notchBlackOpacityAnimation;
  late Animation<double> _photoContainerAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Top white container animation (slides from top)
    _topWhiteController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _topWhiteAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _topWhiteController,
      curve: Curves.easeOutCubic,
    ));

    // Bottom black container animation (slides from bottom)
    _bottomBlackController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bottomBlackAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bottomBlackController,
      curve: Curves.easeOutCubic,
    ));

    // Notch black container animation (slides down from center)
    _notchBlackController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _notchBlackSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _notchBlackController,
      curve: Curves.easeOutCubic,
    ));
    _notchBlackOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _notchBlackController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Photo container animation
    _photoContainerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _photoContainerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70.0,
      ),
    ]).animate(_photoContainerController);

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start white and black container animations simultaneously
    await Future.delayed(const Duration(milliseconds: 100));
    _topWhiteController.forward();
    _bottomBlackController.forward();
    _notchBlackController.forward();

    // Wait for containers to finish
    await Future.delayed(const Duration(milliseconds: 2000));

    // Start photo container animation
    _photoContainerController.forward();

    // Wait for photo
    await Future.delayed(const Duration(milliseconds: 300));

    // Start text animation
    _textController.forward();

    // Wait for all animations to complete plus hold time
    await Future.delayed(const Duration(seconds: 3));

    // Reverse animations before popping
    await Future.wait([
      _textController.reverse(),
      _photoContainerController.reverse(),
    ]);
    await Future.delayed(const Duration(milliseconds: 300));
    await Future.wait([
      _topWhiteController.reverse(),
      _bottomBlackController.reverse(),
      _notchBlackController.reverse(),
    ]);

    // Pop back to previous screen
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _topWhiteController.dispose();
    _bottomBlackController.dispose();
    _notchBlackController.dispose();
    _photoContainerController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top white container with slide animation
          AnimatedBuilder(
            animation: _topWhiteAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    MediaQuery.of(context).size.height *
                        _topWhiteAnimation.value),
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              );
            },
          ),

          // Bottom black container with slide animation
          AnimatedBuilder(
            animation: _bottomBlackAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    MediaQuery.of(context).size.height *
                        _bottomBlackAnimation.value *
                        0.6),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: FadeTransition(
                      opacity: _textAnimation,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            'Your photos will be\nready in 8.5 hours',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Notch black container with slide and fade animations
          AnimatedBuilder(
            animation: _notchBlackController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.38,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).size.height *
                        _notchBlackSlideAnimation.value *
                        0.6,
                  ),
                  child: FadeTransition(
                    opacity: _notchBlackOpacityAnimation,
                    child: Stack(
                      children: [
                        // Container with shadow
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 40.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),

                        // Photo content with printing animation
                        AnimatedBuilder(
                          animation: _photoContainerAnimation,
                          builder: (context, child) {
                            final double heightProgress =
                                _photoContainerAnimation.value;
                            final double containerHeight =
                                MediaQuery.of(context).size.height * 0.15;
                            final double maxAdditionalHeight =
                                containerHeight * 0.2;

                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 40.w),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              height: containerHeight +
                                  (maxAdditionalHeight * heightProgress),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16.r),
                                  bottomRight: Radius.circular(16.r),
                                ),
                                child: Stack(
                                  children: [
                                    // Blurred photo
                                    ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Image.file(
                                        File(widget.photo.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    // Dark overlay with fade
                                    Opacity(
                                      opacity:
                                          (1 - heightProgress).clamp(0.3, 1.0),
                                      child: Container(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Route<dynamic> route({required XFile photo}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          PhotoPreviewScreen(
        photo: photo,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
