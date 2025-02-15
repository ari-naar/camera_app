import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'navigation/navigation_controller.dart';
import 'theme/theme_provider.dart';
import 'services/haptics_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Failed to get cameras: $e');
    cameras = [];
  }

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool('hasCompletedOnboarding') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Initialize haptics service
  await HapticsService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(prefs),
      child: MyApp(
        initialRoute:
            hasCompletedOnboarding ? (isLoggedIn ? '/home' : '/home') : '/home',
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Camera App',
          theme: themeProvider.theme,
          initialRoute: initialRoute,
          onGenerateRoute: NavigationController.onGenerateRoute,
        );
      },
    );
  }
}
