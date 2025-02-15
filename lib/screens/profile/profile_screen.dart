import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hapticsEnabled = true;
  bool _notificationsEnabled = true;
  bool _isEditingUsername = false;
  final _usernameController = TextEditingController(text: 'johndoe');
  final _usernameFocusNode = FocusNode();
  static const String _hapticsKey = 'haptics_enabled';
  static const String _notificationsKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus && _isEditingUsername) {
        setState(() {
          _isEditingUsername = false;
        });
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    });
  }

  Future<void> _updateHaptics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, value);
    setState(() {
      _hapticsEnabled = value;
    });
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    setState(() {
      _notificationsEnabled = value;
    });
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: theme.listTileTheme.contentPadding,
          title: Text(
            title,
            style: theme.listTileTheme.titleTextStyle?.copyWith(
              color: titleColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: theme.listTileTheme.subtitleTextStyle,
                )
              : null,
          trailing: trailing,
        ),
        if (showDivider)
          Divider(
            color: theme.dividerTheme.color,
            indent: 20.w,
            endIndent: 20.w,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      child: Text(
        title,
        style: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildUsernameField() {
    final theme = Theme.of(context);

    if (_isEditingUsername) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        child: TextField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            border: theme.inputDecorationTheme.border,
            enabledBorder: theme.inputDecorationTheme.enabledBorder,
            focusedBorder: theme.inputDecorationTheme.focusedBorder,
            contentPadding: theme.inputDecorationTheme.contentPadding,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
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
        color: theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            color: theme.iconTheme.color,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: theme.appBarTheme.titleTextStyle,
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
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedUserAdd01,
                      color: theme.iconTheme.color,
                      size: 40.sp,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedCamera01,
                        color: theme.brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
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
              title: 'Notifications',
              trailing: CupertinoSwitch(
                value: _notificationsEnabled,
                onChanged: _updateNotifications,
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingItem(
              title: 'Haptic Feedback',
              trailing: CupertinoSwitch(
                value: _hapticsEnabled,
                onChanged: _updateHaptics,
                activeColor: Colors.blue,
              ),
            ),
            _buildSettingItem(
              title: 'Dark Mode',
              trailing: CupertinoSwitch(
                value: context.watch<ThemeProvider>().isDarkMode,
                onChanged: (value) {
                  if (_hapticsEnabled) {
                    HapticFeedback.lightImpact();
                  }
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
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
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
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
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
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
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
