import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

class UserProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String avatar;
  final int photos;
  final int friends;

  const UserProfileScreen({
    super.key,
    required this.name,
    required this.username,
    required this.avatar,
    required this.photos,
    required this.friends,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFriend = false;

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
                          image: DecorationImage(
                            image: NetworkImage(widget.avatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Name
                      Text(
                        widget.name,
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
                        widget.username,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15.sp,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStat('Photos', widget.photos.toString()),
                          Container(
                            width: 1,
                            height: 24.h,
                            margin: EdgeInsets.symmetric(horizontal: 24.w),
                            color: Colors.white24,
                          ),
                          _buildStat('Friends', widget.friends.toString()),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Add Friend Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isFriend = !_isFriend;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFriend ? Colors.white12 : Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFriend
                                  ? HugeIcons.strokeRoundedUserMinus01
                                  : HugeIcons.strokeRoundedUserAdd01,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _isFriend ? 'Remove Friend' : 'Add Friend',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Photos Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Photos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.w,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://picsum.photos/300/300?random=$index'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
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
}
