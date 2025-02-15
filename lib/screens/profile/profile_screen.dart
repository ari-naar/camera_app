import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hapticsEnabled = true;
  bool _isEditingUsername = false;
  final _usernameController = TextEditingController(text: 'johndoe');
  final _usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus && _isEditingUsername) {
        setState(() {
          _isEditingUsername = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? titleColor,
    bool showDivider = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13.sp,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                )
              : null,
          trailing: trailing,
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.1),
            indent: 20.w,
            endIndent: 20.w,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    if (_isEditingUsername) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        child: TextField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            letterSpacing: -0.3,
          ),
          decoration: InputDecoration(
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
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white70,
                size: 16.sp,
              ),
              onPressed: () {
                _usernameFocusNode.unfocus();
                setState(() {
                  _isEditingUsername = false;
                });
              },
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              _isEditingUsername = false;
            });
          },
        ),
      );
    }

    return _buildSettingItem(
      title: 'Username',
      subtitle: '@${_usernameController.text}',
      trailing: Icon(
        HugeIcons.strokeRoundedEdit01,
        color: Colors.white70,
        size: 16.sp,
      ),
      onTap: () {
        setState(() {
          _isEditingUsername = true;
        });
        _usernameFocusNode.requestFocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Profile Image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedUserAdd01,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedCamera01,
                        color: Colors.black,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Account Section
            _buildSectionHeader('ACCOUNT'),
            _buildUsernameField(),
            _buildSettingItem(
              title: 'Email',
              subtitle: 'john.doe@example.com',
              trailing: const SizedBox.shrink(),
            ),

            // Preferences Section
            _buildSectionHeader('PREFERENCES'),
            _buildSettingItem(
              title: 'Haptic Feedback',
              trailing: CupertinoSwitch(
                value: _hapticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _hapticsEnabled = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingItem(
              title: 'Dark Mode',
              trailing: CupertinoSwitch(
                value: context.watch<ThemeProvider>().isDarkMode,
                onChanged: (value) {
                  context.read<ThemeProvider>().setDarkMode(value);
                },
                activeColor: Colors.blue,
              ),
            ),

            // About Section
            _buildSectionHeader('ABOUT'),
            _buildSettingItem(
              title: 'Terms & Conditions',
              trailing: Icon(
                HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white70,
                size: 16.sp,
              ),
              onTap: () {
                // TODO: Navigate to Terms & Conditions
              },
            ),
            _buildSettingItem(
              title: 'Privacy Policy',
              trailing: Icon(
                HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white70,
                size: 16.sp,
              ),
              onTap: () {
                // TODO: Navigate to Privacy Policy
              },
            ),
            _buildSettingItem(
              title: 'App Version',
              subtitle: '1.0.0',
              trailing: Icon(
                HugeIcons.strokeRoundedInformationCircle,
                color: Colors.white70,
                size: 16.sp,
              ),
            ),

            SizedBox(height: 32.h),

            // Sign Out Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSettingItem(
                title: 'Sign Out',
                titleColor: Colors.red,
                trailing: Icon(
                  HugeIcons.strokeRoundedLogout01,
                  color: Colors.red,
                  size: 16.sp,
                ),
                onTap: () {
                  // TODO: Implement sign out
                },
                showDivider: false,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
