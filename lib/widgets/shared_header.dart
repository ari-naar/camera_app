import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../navigation/navigation_controller.dart';
import '../screens/social/social_feed_screen.dart';

class SharedHeader extends StatelessWidget implements PreferredSizeWidget {
  const SharedHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, right: 8.w),
      width: 56.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.grey.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Button
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
                  image: NetworkImage('https://i.pravatar.cc/150?img=1'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Calendar Button
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withOpacity(0.5),
                builder: (context) => CalendarOverlay(
                  photos: const [], // TODO: Pass photos from parent
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
            icon: Icon(
              HugeIcons.strokeRoundedCalendar01,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          // Add Friend Button
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withOpacity(0.5),
                builder: (context) => const AddFriendModal(),
              );
            },
            icon: Icon(
              HugeIcons.strokeRoundedUserAdd01,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
