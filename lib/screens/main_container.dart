import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'social/social_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => MainContainerState();
}

class MainContainerState extends State<MainContainer> {
  final PageController _pageController = PageController(initialPage: 0);
  bool _isSwipingEnabled = true;

  static MainContainerState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainContainerState>();
  }

  PageController get pageController => _pageController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void setSwipingEnabled(bool enabled) {
    setState(() {
      _isSwipingEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: _isSwipingEnabled
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: [
        HomeScreen(onSwipeStateChanged: setSwipingEnabled),
        const SocialScreen(),
      ],
    );
  }
}
