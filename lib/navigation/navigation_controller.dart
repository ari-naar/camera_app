import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/main_container.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/preview/photo_preview_screen.dart';

class NavigationController {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/home':
        final photos = settings.arguments as List<XFile>?;
        return MaterialPageRoute(
            builder: (_) => MainContainer(todayPhotos: photos));
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/preview':
        final photo = settings.arguments as XFile;
        return MaterialPageRoute(
          builder: (_) => PhotoPreviewScreen(photo: photo),
        );
      default:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    }
  }

  static void navigateToAuth(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  static void navigateToHome(BuildContext context, [List<XFile>? photos]) {
    Navigator.pushReplacementNamed(context, '/home', arguments: photos);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToPreview(BuildContext context, XFile photo) {
    Navigator.pushNamed(context, '/preview', arguments: photo);
  }
}
