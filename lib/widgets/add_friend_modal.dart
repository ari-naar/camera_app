import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../screens/profile/user_profile_screen.dart';

class AddFriendModal extends StatefulWidget {
  const AddFriendModal({super.key});

  @override
  State<AddFriendModal> createState() => _AddFriendModalState();
}

class _AddFriendModalState extends State<AddFriendModal> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock data for suggested friends
  final List<Map<String, dynamic>> _suggestedFriends = [
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

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                name: friend['name'],
                username: friend['username'],
                avatar: friend['avatar'],
                photos: friend['photos'],
                friends: friend['friends'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1.w,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(friend['avatar']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      friend['username'],
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
              TextButton(
                onPressed: () {
                  // TODO: Implement add friend functionality
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedUserAdd01,
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Add',
                      style: TextStyle(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar and header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Text(
                      'Add Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      letterSpacing: -0.3,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by username or email',
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
                SizedBox(height: 8.h),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isSearching
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 15.sp,
                        letterSpacing: -0.3,
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      Text(
                        'Suggested Friends',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ..._suggestedFriends.map(_buildFriendCard),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
