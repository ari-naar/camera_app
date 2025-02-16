import 'package:camera/camera.dart';

class SocialPhoto {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String photoUrl;
  final DateTime captureTime;
  final DateTime unlockTime;
  final bool isUnlocked;
  final int likeCount;
  final bool isLikedByMe;
  final List<Comment> comments;
  final String? caption;

  const SocialPhoto({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.photoUrl,
    required this.captureTime,
    required this.unlockTime,
    required this.isUnlocked,
    required this.likeCount,
    required this.isLikedByMe,
    required this.comments,
    this.caption,
  });
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String text;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
  });
}
