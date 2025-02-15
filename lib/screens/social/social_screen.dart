import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

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
      imageUrl: "https://picsum.photos/500/500",
      likes: 127,
      comments: 23,
      isLiked: false,
    ),
    SocialPost(
      username: "Mike",
      timeAgo: "4h ago",
      imageUrl: "https://picsum.photos/501/501",
      likes: 89,
      comments: 12,
      isLiked: true,
    ),
    SocialPost(
      username: "Emma",
      timeAgo: "6h ago",
      imageUrl: "https://picsum.photos/502/502",
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
            icon: Icons.person_add_outlined,
            onTap: () {
              // TODO: Implement friend requests
            },
          ),
          _buildActionButton(
            icon: Icons.notifications_outlined,
            onTap: () {
              // TODO: Implement notifications
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: topPadding + kToolbarHeight,
          bottom: 16.h,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post, index);
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
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
      child: Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!.withOpacity(0.8),
              Colors.grey[850]!.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post),
                _buildPostImage(post),
                _buildPostActions(post),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(SocialPost post) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Hero(
            tag: 'profile_${post.username}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to profile
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(post.imageUrl),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 20.sp,
            ),
            onPressed: () {
              // TODO: Show post options
            },
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(SocialPost post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              post.isLiked = !post.isLiked;
              if (post.isLiked) {
                post.likes++;
              } else {
                post.likes--;
              }
            });
            _animationController.forward(from: 0.0);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
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
              ),
              ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                )),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _animationController.value,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 72.sp,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '1/5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostActions(SocialPost post) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildActionIconButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
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
              SizedBox(width: 16.w),
              _buildActionIconButton(
                icon: Icons.chat_bubble_outline,
                count: post.comments.toString(),
                onTap: () {
                  // TODO: Show comments
                },
              ),
              const Spacer(),
              _buildActionIconButton(
                icon: Icons.share_outlined,
                onTap: () {
                  // TODO: Share post
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    String? count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 22.sp,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              if (count != null) ...[
                SizedBox(width: 6.w),
                Text(
                  count,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SocialPost {
  final String username;
  final String timeAgo;
  final String imageUrl;
  int likes;
  final int comments;
  bool isLiked;

  SocialPost({
    required this.username,
    required this.timeAgo,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}
