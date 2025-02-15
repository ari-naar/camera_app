import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final XFile photo;

  const PhotoPreviewScreen({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // White top section
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            color: Colors.white,
          ),

          // Black bottom section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'Your photos will be ready in 8.5 hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Blurred photo in the middle
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: -50.0, end: 0.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height:
                        (MediaQuery.of(context).size.width * 0.75) * (9 / 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Stack(
                        children: [
                          // Blurred photo
                          ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Image.file(
                              File(photo.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          // Darkening overlay
                          Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
