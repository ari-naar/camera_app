import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/main_container.dart';
import '../screens/gallery/gallery_screen.dart';

class NavigationController {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainContainer());
      case '/gallery':
        final photos = settings.arguments as List<XFile>?;
        return GalleryScreen.route(photos: photos);
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

  static void navigateToGallery(BuildContext context, List<XFile>? photos) {
    Navigator.pushNamed(context, '/gallery', arguments: photos);
  }
}
