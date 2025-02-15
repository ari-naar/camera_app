import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 20.sp,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        letterSpacing: -0.3,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 13.sp,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      labelMedium: TextStyle(
        color: Colors.white54,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      subtitleTextStyle: TextStyle(
        color: Colors.white54,
        fontSize: 13.sp,
        height: 1.3,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: Colors.blue,
    ),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 20.sp,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: 15.sp,
        letterSpacing: -0.3,
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
        fontSize: 13.sp,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      labelMedium: TextStyle(
        color: Colors.black54,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black.withOpacity(0.1),
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      subtitleTextStyle: TextStyle(
        color: Colors.black54,
        fontSize: 13.sp,
        height: 1.3,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: Colors.blue,
    ),
  );
}
