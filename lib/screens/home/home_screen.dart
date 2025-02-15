import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../main.dart';
import '../../navigation/navigation_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _setZoomLevel(_baseZoomLevel * details.scale);
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

  bool _isCapturing = false;

  void _showCapturePreview() {
    if (_capturedPhotos.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  File(_capturedPhotos.last.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_photosLeft photos left today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
      onDoubleTap: _handleDoubleTap,
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
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(24.h),
                child: Text(
                  '$_photosLeft photos left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
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
                  const SizedBox(width: 48),

                // Shutter Button
                GestureDetector(
                  onTap: _photosLeft > 0 ? _capturePhoto : null,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 48),
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
