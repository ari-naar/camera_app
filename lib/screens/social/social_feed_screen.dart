import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'dart:ui';
import '../../models/social_photo.dart';
import '../../navigation/navigation_controller.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _commentController;
  late Animation<double> _commentSlideAnimation;
  late Animation<double> _commentFadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentInputController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isCommentEmpty = true;
  SocialPhoto? _activeCommentPhoto;

  // Mock data for testing
  List<SocialPhoto> _photos = [];

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

    _commentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _commentSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _commentController,
      curve: Curves.easeOutCubic,
    ));
    _commentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _commentController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _loadMockPhotos();

    _commentInputController.addListener(() {
      setState(() {
        _isCommentEmpty = _commentInputController.text.trim().isEmpty;
      });
    });

    _commentFocus.addListener(() {
      if (!_commentFocus.hasFocus && mounted) {
        _hideCommentInput();
      }
    });
  }

  void _loadMockPhotos() {
    // Mock data for testing
    final now = DateTime.now();
    setState(() {
      _photos = [
        SocialPhoto(
          id: '1',
          userId: 'user1',
          username: 'Sarah',
          userAvatar: 'https://i.pravatar.cc/150?img=1',
          photoUrl: 'https://picsum.photos/800/800?random=1',
          captureTime: now.subtract(const Duration(hours: 2)),
          unlockTime: now.add(const Duration(hours: 6)),
          isUnlocked: true,
          likeCount: 12,
          isLikedByMe: false,
          comments: [
            Comment(
              id: 'c1',
              userId: 'user2',
              username: 'Mike',
              userAvatar: 'https://i.pravatar.cc/150?img=2',
              text: 'Can\'t wait to see this!',
              timestamp: now.subtract(const Duration(minutes: 30)),
            ),
          ],
          caption: 'Today was amazing! 📸✨',
        ),
        SocialPhoto(
          id: '2',
          userId: 'user3',
          username: 'Emma',
          userAvatar: 'https://i.pravatar.cc/150?img=3',
          photoUrl: 'https://picsum.photos/800/800?random=2',
          captureTime: now.subtract(const Duration(hours: 5)),
          unlockTime: now.add(const Duration(hours: 3)),
          isUnlocked: false,
          likeCount: 8,
          isLikedByMe: true,
          comments: [],
          caption: 'Perfect weather for photography',
        ),
        // Add more mock photos as needed
      ];
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    _commentInputController.dispose();
    _commentFocus.dispose();
    super.dispose();
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

  Widget _buildPhotoCard(SocialPhoto photo) {
    final size = MediaQuery.of(context).size;
    final photoSize = size.width * 0.85;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 1.w,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(photo.userAvatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _getTimeString(photo.captureTime),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.sp,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Photo container with frame effect
          GestureDetector(
            onTap: () =>
                NavigationController.navigateToPhotoDetail(context, photo),
            child: Container(
              width: photoSize,
              height: photoSize,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10.h),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.w,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo or blurred placeholder
                    if (photo.isUnlocked)
                      Hero(
                        tag: 'photo_${photo.id}',
                        child: _buildProgressiveImage(photo.photoUrl),
                      )
                    else
                      Hero(
                        tag: 'photo_${photo.id}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildProgressiveImage(photo.photoUrl,
                                shouldBlur: true),
                            Container(color: Colors.black.withOpacity(0.4)),
                            // Lock overlay
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      HugeIcons.strokeRoundedSquareLock02,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'Unlocks in ${_getUnlockTimeString(photo.unlockTime)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Inner frame effect
                    IgnorePointer(
                      child: Stack(
                        children: [
                          // Main inner border
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.5.w,
                              ),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            margin: EdgeInsets.all(12.w),
                          ),
                          // Top-left corner decoration
                          Positioned(
                            top: 28.h,
                            left: 28.w,
                            child: Container(
                              width: 16.w,
                              height: 16.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.r),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.w,
                                  ),
                                  left: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.w,
                                  ),
                                ),
                              ),
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

          // Actions and caption
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action buttons
                Row(
                  children: [
                    _buildActionButton(
                      icon: photo.isLikedByMe
                          ? HugeIcons.solidStandardFavourite
                          : HugeIcons.strokeRoundedFavourite,
                      color: photo.isLikedByMe ? Colors.red : Colors.white,
                      count: photo.likeCount,
                      onTap: () {
                        // TODO: Implement like functionality
                      },
                    ),
                    SizedBox(width: 18.w),
                    _buildActionButton(
                      icon: HugeIcons.strokeRoundedMessage01,
                      count: photo.comments.length,
                      onTap: () {
                        if (!photo.isUnlocked) return;
                        _showCommentInput(context, photo);
                      },
                    ),
                  ],
                ),

                if (!photo.isUnlocked) ...[
                  // Blurred placeholder text for locked photos
                  if (photo.caption != null) ...[
                    SizedBox(height: 12.h),
                    ClipRect(
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
                  ],
                  if (photo.comments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            'Comments will be revealed when unlocked',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13.sp,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  // Regular caption and comments for unlocked photos
                  if (photo.caption != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      photo.caption!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                  if (photo.comments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => _showCommentsOverlay(context, photo),
                      child: Text(
                        '${photo.comments.last.username}: ${photo.comments.last.text}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.sp,
              letterSpacing: -0.3,
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

  String _getUnlockTimeString(DateTime unlockTime) {
    final now = DateTime.now();
    final difference = unlockTime.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  void _showCommentsOverlay(BuildContext context, SocialPhoto photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CommentsOverlay(
        photo: photo,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showCommentInput(BuildContext context, SocialPhoto photo) {
    setState(() {
      _activeCommentPhoto = photo;
    });
    _commentController.forward();
    _commentFocus.requestFocus();
  }

  void _hideCommentInput() async {
    _commentFocus.unfocus();
    await _commentController.reverse();
    if (mounted) {
      setState(() {
        _activeCommentPhoto = null;
        _commentInputController.clear();
      });
    }
  }

  Widget _buildFloatingCommentInput() {
    if (_activeCommentPhoto == null) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: FadeTransition(
        opacity: _commentFadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_commentSlideAnimation),
          child: GestureDetector(
            onTap: () {}, // Prevent taps from passing through
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tap to dismiss area
                GestureDetector(
                  onTap: _hideCommentInput,
                  child: Container(
                    height: 100.h,
                    color: Colors.transparent,
                  ),
                ),
                // Comment input
                CommentInputField(
                  controller: _commentInputController,
                  focusNode: _commentFocus,
                  onSubmit: () {
                    // TODO: Implement comment posting
                    _hideCommentInput();
                  },
                  onFocusLost: _hideCommentInput,
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCalendarOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CalendarOverlay(
        photos: _photos,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    title: Text(
                      'Daily Feed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    leading: IconButton(
                      onPressed: () {
                        // TODO: Implement add user functionality
                      },
                      icon: Icon(
                        HugeIcons.strokeRoundedUserAdd01,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => _showCalendarOverlay(context),
                        icon: Icon(
                          HugeIcons.strokeRoundedCalendar01,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          NavigationController.navigateToProfile(context);
                        },
                        icon: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.w,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=1'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w), // Add some padding at the end
                    ],
                  ),

                  // Photo List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (_photos.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40.w,
                                vertical: 60.h,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      HugeIcons.strokeRoundedImageAdd01,
                                      color: Colors.white54,
                                      size: 48.sp,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  Text(
                                    'No photos yet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Photos from your friends will appear here.\nTake some photos to share with them!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 15.sp,
                                      height: 1.4,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return _buildPhotoCard(_photos[index]);
                      },
                      childCount: _photos.isEmpty ? 1 : _photos.length,
                    ),
                  ),

                  // Bottom spacing
                  SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
                ],
              ),
            ),
            _buildFloatingCommentInput(),
          ],
        ),
      ),
    );
  }
}

class CommentsOverlay extends StatefulWidget {
  final SocialPhoto photo;
  final VoidCallback onClose;

  const CommentsOverlay({
    super.key,
    required this.photo,
    required this.onClose,
  });

  @override
  State<CommentsOverlay> createState() => _CommentsOverlayState();
}

class _CommentsOverlayState extends State<CommentsOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isCommentEmpty = _commentController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white24,
                width: 1.w,
              ),
              image: DecorationImage(
                image: NetworkImage(comment.userAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
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
                        color: Colors.white38,
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
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                      'Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.photo.comments.length}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
          // Comments list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              itemCount: widget.photo.comments.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(widget.photo.comments[index]);
              },
            ),
          ),
          // Comment input
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            ),
            child: CommentInputField(
              controller: _commentController,
              focusNode: _commentFocus,
              onSubmit: () {
                // TODO: Implement comment posting
                _commentController.clear();
              },
              margin: EdgeInsets.all(16.w),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentInputField extends StatefulWidget {
  final VoidCallback? onSubmit;
  final EdgeInsets? contentPadding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final VoidCallback? onFocusLost;

  const CommentInputField({
    super.key,
    this.onSubmit,
    this.contentPadding,
    this.margin,
    this.backgroundColor,
    this.focusNode,
    this.controller,
    this.onFocusLost,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(() {
      setState(() {
        _isCommentEmpty = _controller.text.trim().isEmpty;
      });
    });

    if (widget.onFocusLost != null) {
      _focusNode.addListener(() {
        if (!_focusNode.hasFocus) {
          widget.onFocusLost!();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.contentPadding ?? EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  letterSpacing: -0.3,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 15.sp,
                    letterSpacing: -0.3,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _isCommentEmpty
                    ? null
                    : () {
                        widget.onSubmit?.call();
                        _controller.clear();
                      },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 4.w),
                  child: Icon(
                    HugeIcons.strokeRoundedComment01,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarOverlay extends StatefulWidget {
  final List<SocialPhoto> photos;
  final VoidCallback onClose;

  const CalendarOverlay({
    super.key,
    required this.photos,
    required this.onClose,
  });

  @override
  State<CalendarOverlay> createState() => _CalendarOverlayState();
}

class _CalendarOverlayState extends State<CalendarOverlay> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<SocialPhoto>> _photosByDate;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _photosByDate = _groupPhotosByDate();
  }

  Map<DateTime, List<SocialPhoto>> _groupPhotosByDate() {
    final Map<DateTime, List<SocialPhoto>> grouped = {};
    for (var photo in widget.photos) {
      final date = DateTime(
        photo.captureTime.year,
        photo.captureTime.month,
        photo.captureTime.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(photo);
    }
    return grouped;
  }

  List<SocialPhoto> _getPhotosForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _photosByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                      'Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Calendar
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white54,
                  size: 24.sp,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white54,
                  size: 24.sp,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 13.sp,
                  letterSpacing: -0.2,
                ),
                weekendStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 13.sp,
                  letterSpacing: -0.2,
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  letterSpacing: -0.3,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.sp,
                  letterSpacing: -0.3,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.white24,
                  fontSize: 15.sp,
                  letterSpacing: -0.3,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _getPhotosForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
          // Selected day's photos
          Container(
            height: 120.h,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _getPhotosForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                final photo = _getPhotosForDay(_selectedDay)[index];
                return Container(
                  width: 88.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(photo.photoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
