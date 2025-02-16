import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/social_photo.dart';

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
      height: MediaQuery.of(context).size.height * 0.65,
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
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 4.h),
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
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  HugeIcons.strokeRoundedArrowLeft01,
                  color: Colors.white54,
                  size: 24.sp,
                ),
                rightChevronIcon: Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.white54,
                  size: 24.sp,
                ),
                rightChevronVisible: true,
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
            child: _getPhotosForDay(_selectedDay).isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedAlbumNotFound02,
                          color: Colors.white38,
                          size: 24.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No photos taken on this day',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13.sp,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
