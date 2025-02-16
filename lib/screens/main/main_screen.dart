import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../social/social_feed_screen.dart';
import '../../widgets/shared_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  bool _showHeader = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleHeader() {
    setState(() {
      _showHeader = !_showHeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onLongPress: _toggleHeader,
            child: Stack(
              children: [
                // Full screen content
                PageView(
                  controller: _pageController,
                  children: const [
                    _HomeContent(),
                    _SocialContent(),
                  ],
                ),

                // Header overlay with animation
                if (_showHeader)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _showHeader ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const SharedHeader(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return const HomeScreen(showHeader: false);
  }
}

class _SocialContent extends StatelessWidget {
  const _SocialContent();

  @override
  Widget build(BuildContext context) {
    return const SocialFeedScreen(showHeader: false);
  }
}
