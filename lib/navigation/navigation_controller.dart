import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/preview/photo_preview_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/social/social_feed_screen.dart';
import '../screens/social/photo_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/add_friend_screen.dart';
import '../models/social_photo.dart';

class NavigationController {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/preview':
        final photo = settings.arguments as XFile;
        return MaterialPageRoute(
          builder: (_) => PhotoPreviewScreen(photo: photo),
        );
      case '/social':
        return MaterialPageRoute(builder: (_) => const SocialFeedScreen());
      case '/photo-detail':
        final photo = settings.arguments as SocialPhoto;
        return PhotoDetailRoute(photo: photo);
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/add-friend':
        return MaterialPageRoute(builder: (_) => const AddFriendScreen());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    }
  }

  static void navigateToAuth(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToAddFriend(BuildContext context) {
    Navigator.pushNamed(context, '/add-friend');
  }

  static void navigateToPreview(BuildContext context, XFile photo) {
    Navigator.pushNamed(context, '/preview', arguments: photo);
  }

  static void navigateToSocial(BuildContext context) {
    Navigator.pushNamed(context, '/social');
  }

  static void navigateToPhotoDetail(BuildContext context, SocialPhoto photo) {
    Navigator.pushNamed(context, '/photo-detail', arguments: photo);
  }
}
