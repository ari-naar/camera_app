import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import 'package:hugeicons/hugeicons.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  final List<SocialPost> _posts = [
    SocialPost(
      username: "Sarah",
      timeAgo: "2h ago",
      imageUrls: [
        "https://picsum.photos/500/800",
        "https://picsum.photos/500/801",
        "https://picsum.photos/500/802",
      ],
      likes: 127,
      comments: 23,
      isLiked: false,
    ),
    SocialPost(
      username: "Mike",
      timeAgo: "4h ago",
      imageUrls: [
        "https://picsum.photos/501/800",
      ],
      likes: 89,
      comments: 12,
      isLiked: true,
    ),
    SocialPost(
      username: "Emma",
      timeAgo: "6h ago",
      imageUrls: [
        "https://picsum.photos/502/800",
        "https://picsum.photos/502/801",
      ],
      likes: 234,
      comments: 45,
      isLiked: false,
    ),
  ];

  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showAppBarBackground = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showAppBarBackground = _scrollController.offset > 20;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTodayPhotos() {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5, // Maximum 5 photos per day
        itemBuilder: (context, index) {
          return Container(
            width: 60.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.white24,
                width: 1.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photoTaken != null
                      ? Image.file(
                          File(photoTaken.path),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                  // Lock overlay for unrevealed photos
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        HugeIcons.strokeRoundedLock,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showAppBarBackground
            ? Colors.black.withOpacity(0.8)
            : Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: _showAppBarBackground
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
            : null,
        title: Text(
          'Social',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'LL Dot',
          ),
        ),
        actions: [
          _buildActionButton(
            icon: HugeIcons.strokeRoundedUserAdd01,
            onTap: () {
              _showFriendSearchModal();
            },
          ),
          _buildActionButton(
            icon: HugeIcons.strokeRoundedNotification02,
            onTap: () {
              // TODO: Implement notifications
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Top padding to account for app bar
          SizedBox(height: topPadding + kToolbarHeight),

          // Today's photos
          _buildTodayPhotos(),

          // Posts list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(bottom: 16.h),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 18.sp,
      ),
      // padding: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  void _showFriendSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Header
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Text(
                        'Add Friends',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by username or email',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          HugeIcons.strokeRoundedSearch01,
                          color: Colors.white.withOpacity(0.5),
                          size: 18.sp,
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

                SizedBox(height: 16.h),

                // Suggested friends section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Text(
                        'Suggested Friends',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Suggested friends list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount:
                        10, // Replace with actual suggested friends count
                    itemBuilder: (context, index) {
                      return _buildFriendItem(
                        imageUrl: "https://picsum.photos/200/200?random=$index",
                        username: "User ${index + 1}",
                        mutualFriends: "${index + 2} mutual friends",
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendItem({
    required String imageUrl,
    required String username,
    required String mutualFriends,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 12.w),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  mutualFriends,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          // Add button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Implement add friend functionality
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(SocialPost post, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: NetworkImage(post.imageUrls[0]),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  HugeIcons.strokeRoundedMoreVertical,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),

          // Image with action buttons
          Stack(
            children: [
              // Image carousel
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildPostImage(post),
              ),

              // Vertical action buttons
              Positioned(
                right: 12.w,
                bottom: 24.h,
                child: Column(
                  children: [
                    _buildVerticalActionButton(
                      icon: post.isLiked
                          ? HugeIcons.solidStandardFavourite
                          : HugeIcons.strokeRoundedFavourite,
                      color: post.isLiked ? Colors.red : Colors.white,
                      count: post.likes.toString(),
                      onTap: () {
                        setState(() {
                          post.isLiked = !post.isLiked;
                          if (post.isLiked) {
                            post.likes++;
                          } else {
                            post.likes--;
                          }
                        });
                      },
                    ),
                    _buildVerticalActionButton(
                      icon: HugeIcons.strokeRoundedComment02,
                      count: post.comments.toString(),
                      onTap: () {
                        // TODO: Show comments
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Comment section
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add a comment...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalActionButton({
    required IconData icon,
    String? count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
          padding: EdgeInsets.all(0.w),
          constraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 40.w,
          ),
        ),
        if (count != null) ...[
          Transform.translate(
            offset: Offset(0, -6.h),
            child: Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostImage(SocialPost post) {
    final PageController pageController = PageController();
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: post.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onDoubleTap: () {
                        this.setState(() {
                          post.isLiked = !post.isLiked;
                          if (post.isLiked) {
                            post.likes++;
                          } else {
                            post.likes--;
                          }
                        });
                      },
                      child: Image.network(
                        post.imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[900],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (post.imageUrls.length > 1) ...[
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        post.imageUrls.length,
                        (index) => Container(
                          width: 6.w,
                          height: 6.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pageController.hasClients
                                ? (pageController.page?.round() ?? 0) == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5)
                                : index == 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class SocialPost {
  final String username;
  final String timeAgo;
  final List<String> imageUrls;
  int likes;
  final int comments;
  bool isLiked;

  SocialPost({
    required this.username,
    required this.timeAgo,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}
