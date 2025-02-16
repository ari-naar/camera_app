import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:ui';
import '../../models/social_photo.dart';

class PhotoDetailScreen extends StatefulWidget {
  final SocialPhoto photo;

  const PhotoDetailScreen({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _commentController.addListener(() {
      setState(() {
        _isCommentEmpty = _commentController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(comment.userAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _getTimeString(comment.timestamp),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.sp,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15.sp,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeString(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildProgressiveImage(String url, {bool shouldBlur = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Low resolution image first
        Image.network(
          '$url?blur=50',
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            );
          },
        ),
        // High resolution image
        Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return shouldBlur
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: child,
                    )
                  : child;
            }
            return Shimmer.fromColors(
              baseColor: Colors.white24,
              highlightColor: Colors.white38,
              child: Container(
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.sp,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Photo section with Hero animation
          Hero(
            tag: 'photo_${widget.photo.id}',
            child: Material(
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User info header
                  SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              HugeIcons.strokeRoundedArrowLeft01,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(widget.photo.userAvatar),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            widget.photo.username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Photo
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.black,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return FadeTransition(
                              opacity: animation,
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                extendBodyBehindAppBar: true,
                                appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  leading: IconButton(
                                    icon: Icon(
                                      HugeIcons.strokeRoundedArrowLeft01,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    clipBehavior: Clip.none,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: _buildProgressiveImage(
                                        widget.photo.photoUrl,
                                        shouldBlur: !widget.photo.isUnlocked,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildProgressiveImage(
                            widget.photo.photoUrl,
                            shouldBlur: !widget.photo.isUnlocked,
                          ),
                          if (!widget.photo.isUnlocked) ...[
                            Container(color: Colors.black.withOpacity(0.4)),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    HugeIcons.strokeRoundedSquareLock02,
                                    color: Colors.white,
                                    size: 48.sp,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'This photo is still locked',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Come back later to see it!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15.sp,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        // Like button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement like functionality
                          },
                          child: Icon(
                            widget.photo.isLikedByMe
                                ? HugeIcons.solidRoundedFavourite
                                : HugeIcons.strokeRoundedFavourite,
                            color: widget.photo.isLikedByMe
                                ? Colors.red
                                : Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.photo.likeCount.toString(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Comment button
                        GestureDetector(
                          onTap: () {
                            _commentFocus.requestFocus();
                          },
                          child: Icon(
                            HugeIcons.strokeRoundedMessage01,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.photo.comments.length.toString(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
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

          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.photo.isUnlocked) ...[
                  // Blurred placeholder text for locked photos
                  if (widget.photo.caption != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Text(
                              'Caption will be revealed when unlocked',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 15.sp,
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Comments will be revealed when unlocked',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15.sp,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Regular caption and comments for unlocked photos
                  if (widget.photo.caption != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        widget.photo.caption!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: widget.photo.comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentItem(widget.photo.comments[index]);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      letterSpacing: -0.3,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 15.sp,
                        letterSpacing: -0.3,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                AnimatedOpacity(
                  opacity: _isCommentEmpty ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _isCommentEmpty
                        ? null
                        : () {
                            // TODO: Implement comment posting
                            _commentController.clear();
                          },
                    child: Icon(
                      HugeIcons.strokeRoundedSendToMobile,
                      color: Colors.white,
                      size: 24.sp,
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
}

// Route generator
class PhotoDetailRoute extends MaterialPageRoute {
  PhotoDetailRoute({required SocialPhoto photo})
      : super(
          builder: (context) => PhotoDetailScreen(photo: photo),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
