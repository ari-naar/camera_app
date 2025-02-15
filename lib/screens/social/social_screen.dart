import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final List<SocialPost> _posts = [
    SocialPost(
      username: "Sarah",
      timeAgo: "2h ago",
      imageUrl: "https://picsum.photos/500/500",
      likes: 127,
      comments: 23,
    ),
    SocialPost(
      username: "Mike",
      timeAgo: "4h ago",
      imageUrl: "https://picsum.photos/501/501",
      likes: 89,
      comments: 12,
    ),
    SocialPost(
      username: "Emma",
      timeAgo: "6h ago",
      imageUrl: "https://picsum.photos/502/502",
      likes: 234,
      comments: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Social Feed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement friend requests
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(post.imageUrl),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
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
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 300.h,
              fit: BoxFit.cover,
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  post.likes.toString(),
                  () {
                    // TODO: Implement like functionality
                  },
                ),
                SizedBox(width: 16.w),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  post.comments.toString(),
                  () {
                    // TODO: Implement comments functionality
                  },
                ),
                const Spacer(),
                _buildActionButton(
                  Icons.share_outlined,
                  '',
                  () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          if (count.isNotEmpty) ...[
            SizedBox(width: 4.w),
            Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SocialPost {
  final String username;
  final String timeAgo;
  final String imageUrl;
  final int likes;
  final int comments;

  SocialPost({
    required this.username,
    required this.timeAgo,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });
}
