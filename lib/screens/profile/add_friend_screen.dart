import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';
import 'user_profile_screen.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'name': 'Mike Johnson',
      'username': '@mikej',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'photos': 89,
      'friends': 134,
    },
    {
      'name': 'Emma Wilson',
      'username': '@emmaw',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'photos': 156,
      'friends': 223,
    },
    {
      'name': 'David Chen',
      'username': '@davidc',
      'avatar': 'https://i.pravatar.cc/150?img=7',
      'photos': 67,
      'friends': 98,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              'Find Friends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    letterSpacing: -0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 16.sp,
                      letterSpacing: -0.3,
                    ),
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedSearch01,
                      color: Colors.white54,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // User List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildUserCard(_mockUsers[index]),
              childCount: _mockUsers.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  name: user['name'],
                  username: user['username'],
                  avatar: user['avatar'],
                  photos: user['photos'],
                  friends: user['friends'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 1.w,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(user['avatar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user['username'],
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15.sp,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedUserAdd01,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
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
        ),
      ),
    );
  }
}
