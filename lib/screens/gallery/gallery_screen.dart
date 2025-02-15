import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  final List<XFile> photos;

  const GalleryScreen({
    super.key,
    required this.photos,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();

  static Route<dynamic> route({List<XFile>? photos}) {
    return MaterialPageRoute(
      builder: (context) => GalleryScreen(photos: photos ?? []),
    );
  }
}

class _GalleryScreenState extends State<GalleryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;
  Map<String, String> _descriptions = {};

  Map<DateTime, List<XFile>> _groupPhotosByDate() {
    final Map<DateTime, List<XFile>> photosByDate = {};

    for (final photo in widget.photos) {
      final date = File(photo.path).lastModifiedSync();
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (!photosByDate.containsKey(dateOnly)) {
        photosByDate[dateOnly] = [];
      }
      photosByDate[dateOnly]!.add(photo);
    }

    return photosByDate;
  }

  List<XFile> _getPhotosForSelectedDay() {
    final photosByDate = _groupPhotosByDate();
    final selectedDateOnly = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    return photosByDate[selectedDateOnly] ?? [];
  }

  void _showFullScreenImage(XFile photo, int index) {
    final TextEditingController descController = TextEditingController(
      text: _descriptions[photo.path],
    );

    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              InteractiveViewer(
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                ),
              ),
              // Close button at top
              Positioned(
                top: 48,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // Description input and controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from closing the dialog
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: descController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Add a description...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _descriptions.remove(photo.path);
                              } else {
                                _descriptions[photo.path] = value;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolaroidFrame(XFile? photo, int index) {
    final hasDescription =
        photo != null && _descriptions.containsKey(photo.path);

    Widget content = Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: hasDescription ? 4 : 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.photo_camera,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
            ),
          ),
          if (hasDescription)
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text(
                  _descriptions[photo.path]!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    return Transform.rotate(
      angle: (index % 3 == 0) ? 0.02 : -0.02,
      child: photo != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFullScreenImage(photo, index),
                child: content,
              ),
            )
          : content,
    );
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                Navigator.pop(context);
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photosForSelectedDay = _getPhotosForSelectedDay();
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final dateFormat = DateFormat('MMM d, y');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 56, 4, 80),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemHeight = (constraints.maxHeight - 32) / 3;
                  final aspectRatio =
                      (constraints.maxWidth / 2 - 8) / itemHeight;

                  return SingleChildScrollView(
                    physics: keyboardVisible
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(4),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final photo = index < photosForSelectedDay.length
                            ? photosForSelectedDay[index]
                            : null;
                        return _buildPolaroidFrame(photo, index);
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _showCalendarModal,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateFormat.format(_selectedDay),
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
