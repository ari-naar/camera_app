import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../main.dart';
import '../../navigation/navigation_controller.dart';
import '../main_container.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onSwipeStateChanged;

  const HomeScreen({
    super.key,
    required this.onSwipeStateChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _photosLeft = 5;
  List<XFile> _capturedPhotos = [];
  double _minZoomLevel = 0.5;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  int _currentCameraIndex = 0;
  CameraController? _newController;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No cameras available';
      });
      return;
    }

    // Find the primary (1x) rear camera
    final primaryRearCameraIndex = cameras.indexWhere((camera) =>
        camera.lensDirection == CameraLensDirection.back &&
        (camera.sensorOrientation == 90 || camera.sensorOrientation == 270));

    // If primary rear camera not found, use the first available camera
    _currentCameraIndex =
        primaryRearCameraIndex != -1 ? primaryRearCameraIndex : 0;

    // Try different resolution presets in order of preference
    final List<ResolutionPreset> presets = [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    for (final preset in presets) {
      try {
        final controller = CameraController(
          cameras[_currentCameraIndex],
          preset,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await controller.initialize();

        // Force a small delay to ensure camera is fully initialized
        await Future.delayed(const Duration(milliseconds: 100));

        // Set zoom to 1.0x immediately after initialization
        await controller.setZoomLevel(1.0);

        if (mounted) {
          // Get zoom level bounds
          final minZoom = await controller.getMinZoomLevel();
          final maxZoom = await controller.getMaxZoomLevel();

          // Set zoom limits based on camera type
          double effectiveMaxZoom;
          if (cameras[_currentCameraIndex].lensDirection ==
              CameraLensDirection.front) {
            effectiveMaxZoom = math.min(maxZoom, 2.0); // Front camera: max 2x
          } else {
            effectiveMaxZoom = math.min(maxZoom, 25.0); // Rear camera: max 25x
          }

          setState(() {
            _controller = controller;
            _isInitialized = true;
            _hasError = false;
            _errorMessage = '';
            // Allow 0.5x zoom if device supports it
            _minZoomLevel = math.min(0.5, minZoom);
            _maxZoomLevel = effectiveMaxZoom;
            _currentZoomLevel = 1.0;
            _baseZoomLevel = 1.0;
          });
          return;
        } else {
          await controller.dispose();
        }
      } catch (e) {
        debugPrint('Failed to initialize camera with preset $preset: $e');
        continue;
      }
    }

    // If we get here, all presets failed
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize camera. Please try again.';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
    });

    // Find the front camera and primary rear camera indices
    final frontCameraIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    final primaryRearCameraIndex = cameras.indexWhere((camera) =>
        camera.lensDirection == CameraLensDirection.back &&
        (camera.sensorOrientation == 90 || camera.sensorOrientation == 270));

    // Determine which camera to switch to
    int newIndex;
    if (_currentCameraIndex == frontCameraIndex) {
      newIndex = primaryRearCameraIndex != -1 ? primaryRearCameraIndex : 0;
    } else {
      newIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;
    }

    // Dispose of the old controller first
    await _controller?.dispose();
    _controller = null;

    // Initialize the new camera
    try {
      final controller = CameraController(
        cameras[newIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Set the controller variable
      _controller = controller;

      // Wait for the new camera to initialize
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Get zoom level bounds for the new camera
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      // Set zoom limits based on camera type
      double effectiveMaxZoom;
      bool isRearCamera =
          cameras[newIndex].lensDirection == CameraLensDirection.back;

      if (isRearCamera) {
        effectiveMaxZoom = math.min(maxZoom, 25.0); // Rear camera: max 25x
      } else {
        effectiveMaxZoom = math.min(maxZoom, 2.0); // Front camera: max 2x
      }

      // Set zoom to 1.0x
      await controller.setZoomLevel(1.0);

      if (mounted) {
        setState(() {
          _currentCameraIndex = newIndex;
          _minZoomLevel = math.min(0.5, minZoom);
          _maxZoomLevel = effectiveMaxZoom;
          _currentZoomLevel = 1.0;
          _baseZoomLevel = 1.0;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to switch camera: $e');
      // If switching fails, try to reinitialize
      await _initializeCamera();
    }
  }

  Future<void> _setZoomLevel(double level) async {
    if (_controller == null) return;

    // Ensure zoom level is within bounds
    level = level.clamp(_minZoomLevel, _maxZoomLevel);

    try {
      await _controller!.setZoomLevel(level);
      setState(() {
        _currentZoomLevel = level;
      });
    } catch (e) {
      debugPrint('Failed to set zoom level: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    widget.onSwipeStateChanged(false);
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _setZoomLevel(_baseZoomLevel * details.scale);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    widget.onSwipeStateChanged(true);
  }

  void _handleDoubleTap() {
    _switchCamera();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _photosLeft <= 0) {
      return;
    }

    try {
      // Flash animation
      setState(() {
        _isCapturing = true;
      });

      final XFile photo = await _controller!.takePicture();

      setState(() {
        _capturedPhotos.add(photo);
        _photosLeft--;
        _isCapturing = false;
      });

      // Show preview
      _showCapturePreview();
    } catch (e) {
      print('Error capturing photo: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _handleTapToFocus(TapDownDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Provide haptic feedback immediately
    HapticFeedback.selectionClick();

    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * _controller!.value.aspectRatio;
    final actualPreviewSize = Size(
      size.width,
      size.width / _controller!.value.aspectRatio,
    );
    final previewOffset = Offset(
      0,
      (size.height - actualPreviewSize.height) / 2,
    );

    final tapPosition = details.localPosition - previewOffset;
    final proportionalPosition = Offset(
      tapPosition.dx / actualPreviewSize.width,
      tapPosition.dy / actualPreviewSize.height,
    );

    // Set focus point for visual indicator immediately
    setState(() {
      _focusPoint = details.localPosition;
    });

    // Set camera focus and exposure immediately
    try {
      await Future.wait([
        _controller!.setFocusPoint(proportionalPosition),
        _controller!.setExposurePoint(proportionalPosition),
      ]);
    } catch (e) {
      debugPrint('Error setting focus: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      FlashMode newMode;
      switch (_flashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        default:
          newMode = FlashMode.off;
      }

      await _controller!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      default:
        return Icons.flash_off_rounded;
    }
  }

  void _showCapturePreview() {
    if (_capturedPhotos.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.file(
                  File(_capturedPhotos.last.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_photosLeft photos left today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigationController.navigateToGallery(
                        context,
                        _capturedPhotos,
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null ||
        !_isInitialized ||
        !_controller!.value.isInitialized) {
      return Container(color: Colors.black);
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onDoubleTap: _handleDoubleTap,
      onTapDown: _handleTapToFocus,
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48.r,
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          _buildCameraPreview(),

          // Flash overlay
          if (_isCapturing)
            Container(
              color: Colors.white.withOpacity(0.3),
            ),

          // Zoom Level Indicator (only show when not at 1.0x)
          if (_currentZoomLevel != 1.0)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Photos Left Counter
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _photosLeft == 0
                          ? 'No photos left'
                          : _photosLeft == 1
                              ? '$_photosLeft photo left'
                              : '$_photosLeft photos left',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'LL Dot',
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final ancestor = context
                                .findAncestorStateOfType<MainContainerState>();
                            if (ancestor != null) {
                              ancestor.pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              HugeIcons.strokeRoundedUserGroup,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (_currentZoomLevel != 1.0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentZoomLevel.toStringAsFixed(1)}x',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: _toggleFlash,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getFlashIcon(),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Focus point indicator
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 40,
              top: _focusPoint!.dy - 40,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 0.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 - value * 0.3,
                    child: Opacity(
                      opacity: value < 0.7 ? 1.0 - value : 1.0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.yellow,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.yellow,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  setState(() {
                    _focusPoint = null;
                  });
                },
              ),
            ),

          // Camera Controls Row
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery Button (if photos exist)
                if (_capturedPhotos.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      NavigationController.navigateToGallery(
                        context,
                        _capturedPhotos,
                      );
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5.w,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.file(
                          File(_capturedPhotos.last.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(width: 48.w),

                // Shutter Button
                GestureDetector(
                  onTap: _photosLeft > 0 ? _capturePhoto : null,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5.w,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Camera Flip Button
                if (cameras.length > 1)
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5.w,
                        ),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedCameraRotated02,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  )
                else
                  SizedBox(width: 48.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }
}
