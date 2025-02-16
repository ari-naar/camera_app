import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:math' as math;
import '../../main.dart';
import '../../navigation/navigation_controller.dart';
import '../../widgets/shared_header.dart';

class HomeScreen extends StatefulWidget {
  final bool showHeader;

  const HomeScreen({
    super.key,
    this.showHeader = true,
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

        // Set camera to fixed focus mode for everything to be in focus
        await Future.wait([
          controller.setFocusMode(FocusMode.auto),
          controller.setExposureMode(ExposureMode.auto),
          controller.setZoomLevel(1.0),
        ]);

        if (mounted) {
          // Get zoom level bounds
          final minZoom = await controller.getMinZoomLevel();
          final maxZoom = await controller.getMaxZoomLevel();

          // Set zoom limits based on camera type
          double effectiveMaxZoom;
          if (cameras[_currentCameraIndex].lensDirection ==
              CameraLensDirection.front) {
            effectiveMaxZoom = math.min(maxZoom, 2.0);
          } else {
            effectiveMaxZoom = math.min(maxZoom, 25.0);
          }

          setState(() {
            _controller = controller;
            _isInitialized = true;
            _hasError = false;
            _errorMessage = '';
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

      _controller = controller;
      await controller.initialize();

      // Set camera to fixed focus mode for everything to be in focus
      await Future.wait([
        controller.setFocusMode(FocusMode.auto),
        controller.setExposureMode(ExposureMode.auto),
        controller.setZoomLevel(1.0),
      ]);

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
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _setZoomLevel(_baseZoomLevel * details.scale);
  }

  void _handleScaleEnd(ScaleEndDetails details) {}

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
      final XFile photo = await _controller!.takePicture();

      setState(() {
        _capturedPhotos.add(photo);
        _photosLeft--;
      });

      // Show preview
      _showCapturePreview();
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  void _showCapturePreview() {
    if (_capturedPhotos.isEmpty) return;
    NavigationController.navigateToPreview(context, _capturedPhotos.last);
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
                HugeIcons.strokeRoundedCameraOff02,
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
      appBar: widget.showHeader ? const SharedHeader() : null,
      body: Column(
        children: [
          // Shots Counter
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.23),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              _photosLeft == 1 ? '1 SHOT LEFT' : '${_photosLeft} SHOTS LEFT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          // Camera Preview and Shutter Button Container
          Expanded(
            child: Stack(
              children: [
                // Camera Preview
                Center(
                  child: _buildCameraPreview(),
                ),

                // Shutter Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48.h,
                  child: Center(
                    child: GestureDetector(
                      onTap: _photosLeft > 0 ? _capturePhoto : null,
                      child: Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3.w,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    // Calculate viewport dimensions for 16:9 vertical aspect ratio
    final viewportWidth = size.width * 0.6;
    final viewportHeight = viewportWidth * (16 / 9);

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onDoubleTap: _handleDoubleTap,
      child: Container(
        width: viewportWidth,
        height: viewportHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Stack(
          children: [
            // Camera preview
            ClipRRect(
              borderRadius: BorderRadius.circular(32.r),
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

            // Inner border
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.w,
                  ),
                ),
              ),
            ),

            // Top-left corner decoration
            Positioned(
              top: 28.h,
              left: 28.w,
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5.w,
                    ),
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5.w,
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
