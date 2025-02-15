import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/navigation_controller.dart';
import '../../services/haptics_service.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationsEnabled = true;
  bool _isHapticsEnabled = true;
  final _usernameController = TextEditingController(text: 'sarahp');
  final _usernameFocusNode = FocusNode();
  bool _isEditingUsername = false;
  final _hapticsService = HapticsService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isHapticsEnabled = _hapticsService.isEnabled;
    });
  }

  Future<void> _toggleHaptics(bool value) async {
    await _hapticsService.setEnabled(value);
    setState(() {
      _isHapticsEnabled = value;
    });
    if (value) {
      _hapticsService.selectionClick();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _startEditingUsername() {
    setState(() {
      _isEditingUsername = true;
    });
    _usernameFocusNode.requestFocus();
  }

  void _finishEditingUsername() {
    setState(() {
      _isEditingUsername = false;
    });
    // TODO: Save username changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            pinned: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                HugeIcons.strokeRoundedArrowLeft01,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                  child: Column(
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 2.w,
                                ),
                                image: const DecorationImage(
                                  image:
                                      NetworkImage('https://i.pravatar.cc/300'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.w,
                                  ),
                                ),
                                child: Icon(
                                  HugeIcons.strokeRoundedCamera02,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Name (non-editable)
                      Text(
                        'Sarah Parker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Username (editable)
                      GestureDetector(
                        onTap: _startEditingUsername,
                        child: _isEditingUsername
                            ? TextField(
                                controller: _usernameController,
                                focusNode: _usernameFocusNode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15.sp,
                                  letterSpacing: -0.3,
                                ),
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white24,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => _finishEditingUsername(),
                                onEditingComplete: _finishEditingUsername,
                              )
                            : Text(
                                '@${_usernameController.text}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15.sp,
                                  letterSpacing: -0.3,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('Photos', '127'),
                    Container(
                      width: 1,
                      height: 24.h,
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      color: Colors.white24,
                    ),
                    _buildStat('Friends', '48'),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Settings Sections
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preferences
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                        child: Text(
                          'Preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedNotification01,
                        title: 'Notifications',
                        trailing: CupertinoSwitch(
                          value: _isNotificationsEnabled,
                          onChanged: (value) {
                            setState(() => _isNotificationsEnabled = value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedTap06,
                        title: 'Haptic Feedback',
                        trailing: CupertinoSwitch(
                          value: _isHapticsEnabled,
                          onChanged: _toggleHaptics,
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Legal & Support
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                        child: Text(
                          'Legal & Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedLegalDocument01,
                        title: 'Terms & Conditions',
                        onTap: () {
                          // TODO: Show T&Cs
                        },
                        trailingIcon: HugeIcons.strokeRoundedLinkSquare01,
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedLock,
                        title: 'Privacy Policy',
                        onTap: () {
                          // TODO: Show Privacy Policy
                        },
                        trailingIcon: HugeIcons.strokeRoundedLinkSquare01,
                      ),
                    ],
                  ),
                ),

                // Sign Out Section
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: _buildSettingsTile(
                    icon: HugeIcons.strokeRoundedLogout01,
                    title: 'Sign Out',
                    textColor: Colors.red,
                    trailing: SizedBox(width: 24.w),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      if (mounted) {
                        NavigationController.navigateToAuth(context);
                      }
                    },
                  ),
                ),

                // Delete Account
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Handle delete account logic (e.g., show confirmation dialog)
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.4),
                    ),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 15.sp,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),

                // App Information
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 72.w,
                        width: 72.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Center(
                          child: Text(
                            'LOGO',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13.sp,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Camera App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Version 1.0.0 (1)',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15.sp,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Text(
                            '© ${DateTime.now().year}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15.sp,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Camera App',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 15.sp,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Made in Sydney',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15.sp,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '🦘',
                            style: TextStyle(
                              fontSize: 15.sp,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 15.sp,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 16.sp,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  trailingIcon ?? HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.white54,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
