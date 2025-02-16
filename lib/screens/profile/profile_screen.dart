import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/navigation_controller.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = true;
  bool _isNotificationsEnabled = true;

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
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Profile Picture
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
                            image: NetworkImage('https://i.pravatar.cc/300'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Name
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
                      // Username
                      Text(
                        '@sarahp',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15.sp,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 16.h),
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
                    ],
                  ),
                ),

                // Settings Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedMoon01,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() => _isDarkMode = value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedNotification01,
                        title: 'Notifications',
                        trailing: Switch(
                          value: _isNotificationsEnabled,
                          onChanged: (value) {
                            setState(() => _isNotificationsEnabled = value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        title: 'Find Friends',
                        onTap: () {
                          NavigationController.navigateToAddFriend(context);
                        },
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedLock,
                        title: 'Privacy',
                        onTap: () {
                          // TODO: Navigate to privacy settings
                        },
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        title: 'About',
                        onTap: () {
                          // TODO: Show about dialog
                        },
                      ),
                      _buildSettingsTile(
                        icon: HugeIcons.strokeRoundedLogout01,
                        title: 'Sign Out',
                        textColor: Colors.red,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);
                          if (mounted) {
                            NavigationController.navigateToAuth(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
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
                  HugeIcons.strokeRoundedArrowRight01,
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
