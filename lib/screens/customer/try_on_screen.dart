import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/wishlist_service.dart';
import '../../services/api_service.dart';
import '../../widgets/clothing_image.dart';

class TryOnScreen extends StatefulWidget {
  final ClothingItem item;
  final String selectedSize;
  final int customerId;

  const TryOnScreen({
    super.key,
    required this.item,
    required this.selectedSize,
    required this.customerId,
  });

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  bool _showOverlay = false;
  int _selectedCameraIndex = 1;
  String _statusMessage = 'Initializing camera...';

  // Overlay Controls
  double _overlayScale = 0.6;      // Zoom: 0.2 to 1.0
  double _overlayOpacity = 0.85;   // Opacity: 0.3 to 1.0
  Offset _overlayPosition = const Offset(0, 0); // Drag position
  Offset _dragStart = Offset.zero;

    // --- Pose detection ---
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  bool _isDetecting = false;   // stops frames from queuing up
  bool _debugLandmarks = true; // shows green dots
  Pose? _pose;                 // latest detected pose
  Size? _imageSize;            // size of the camera image
  Rect? _autoRect;             // garment box calculated from landmarks

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _statusMessage = 'No camera found';
          _isLoading = false;
        });
        return;
      }
      if (_selectedCameraIndex >= _cameras.length) {
        _selectedCameraIndex = 0;
      }
      await _startCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() {
        _statusMessage = 'Camera error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startCamera(int index) async {
    _cameraController = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    try {
      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processCameraImage);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
          _statusMessage = 'Tap "Try-on" to overlay garment';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to start camera: $e';
        _isLoading = false;
      });
    }
  }
  
  // Convert one camera frame into the format ML Kit expects
  InputImage? _toInputImage(CameraImage image) {
    final camera = _cameras[_selectedCameraIndex];
    // Portrait-locked, so the rotation is the camera sensor orientation
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Runs once for every camera frame
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return; // still busy with the previous frame
    _isDetecting = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final poses = await _poseDetector.processImage(input);
      if (!mounted) return;

      // In portrait the camera image is rotated, so width and height swap
      final w = image.width.toDouble();
      final h = image.height.toDouble();
      final rot = input.metadata!.rotation;
      final upright = (rot == InputImageRotation.rotation90deg ||
              rot == InputImageRotation.rotation270deg)
          ? Size(h, w)
          : Size(w, h);

      setState(() {
        _imageSize = upright;
        _pose = poses.isNotEmpty ? poses.first : null;
      });
    } finally {
      _isDetecting = false;
    }
  }

  // Convert a landmark (camera image position) to a screen position
  Offset _toScreen(PoseLandmark l, Size img, Size screen) {
    final isFront = _cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
    final x = l.x * screen.width / img.width;
    final y = l.y * screen.height / img.height;
    return Offset(isFront ? screen.width - x : x, y); // mirror for the front camera
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isLoading = true);
    if (_cameraController?.value.isStreamingImages ?? false) {
      await _cameraController!.stopImageStream();
    }
    await _cameraController?.dispose();
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras.length;
    await _startCamera(_selectedCameraIndex);
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      // Reset position when toggling
      _overlayPosition = const Offset(0, 0);
      _statusMessage = _showOverlay
          ? 'Drag to reposition • Use slider to resize'
          : 'Tap "Try-on" to overlay garment';
    });
  }

  Future<void> _captureScreenshot() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: ${image.path}'),
            backgroundColor: kAccentColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
      _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed
          _buildCameraFeed(),
                    // Debug: green dots on detected body points
          if (_debugLandmarks && _pose != null && _imageSize != null)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _DotsPainter(
                  _pose!.landmarks.values
                      .where((l) => l.likelihood > 0.5)
                      .map((l) => _toScreen(
                          l, _imageSize!, MediaQuery.of(context).size))
                      .toList(),
                ),
              ),
            ),

          // Draggable Garment Overlay
          if (_showOverlay && _isCameraInitialized)
            _buildDraggableOverlay(),

          // Top Bar
          _buildTopBar(),

          // Status Message
          _buildStatusOverlay(),

          // Bottom Controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Try-on',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Camera Feed
  Widget _buildCameraFeed() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            color: kAccentColor),
      );
    }
    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Text(_statusMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
      );
    }
    return CameraPreview(_cameraController!);
  }

  // Draggable Garment Overlay
  Widget _buildDraggableOverlay() {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    return Positioned(
      left: centerX - (screenSize.width * _overlayScale / 2) +
          _overlayPosition.dx,
      top: centerY - (screenSize.width * _overlayScale / 2) +
          _overlayPosition.dy,
      child: GestureDetector(
        // Drag to reposition
        onPanStart: (details) {
          _dragStart = details.globalPosition - _overlayPosition;
        },
        onPanUpdate: (details) {
          setState(() {
            _overlayPosition =
                details.globalPosition - _dragStart;
          });
        },
        child: Opacity(
          opacity: _overlayOpacity,
          child: clothingImage(
            widget.item.arOverlayAsset,
            width: screenSize.width * _overlayScale,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Status Overlay
  Widget _buildStatusOverlay() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusMessage,
            style: const TextStyle(
                color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }

  // Bottom Controls
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Zoom Slider
            if (_showOverlay) ...[
              Row(
                children: [
                  const Icon(Icons.zoom_out,
                      color: Colors.white70, size: 20),
                  Expanded(
                    child: Slider(
                      value: _overlayScale,
                      min: 0.2,
                      max: 1.0,
                      activeColor: kAccentColor,
                      inactiveColor: Colors.white24,
                      onChanged: (val) =>
                          setState(() => _overlayScale = val),
                    ),
                  ),
                  const Icon(Icons.zoom_in,
                      color: Colors.white70, size: 20),
                ],
              ),

              // Opacity Slider
              Row(
                children: [
                  const Icon(Icons.opacity,
                      color: Colors.white70, size: 20),
                  Expanded(
                    child: Slider(
                      value: _overlayOpacity,
                      min: 0.3,
                      max: 1.0,
                      activeColor: kAccentColor,
                      inactiveColor: Colors.white24,
                      onChanged: (val) =>
                          setState(() => _overlayOpacity = val),
                    ),
                  ),
                  const Icon(Icons.brightness_high,
                      color: Colors.white70, size: 20),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Try-on Button
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _isCameraInitialized
                    ? _toggleOverlay
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor),
                child: Text(
                  _showOverlay ? 'Remove' : 'Try-on',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Icon Buttons Row
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.camera_alt,
                  label: 'Screenshot',
                  onTap: _captureScreenshot,
                ),
                _ControlButton(
                  icon: Icons.favorite,
                  label: 'Wishlist',
                  onTap: () async {
                    print('Adding to wishlist: customerId=${widget.customerId}, itemId=${widget.item.id}');
                    final success = await ApiService.instance.addToWishlist(
                      widget.customerId, widget.item.id);
                    print('Wishlist result: $success');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                        ? '${widget.item.name} saved to wishlist!'
                        : 'Already in wishlist or error'),
                      backgroundColor: success ? kAccentColor : Colors.redAccent,
                    ));
                  },
                ),
                _ControlButton(
                  icon: Icons.switch_camera,
                  label: 'Switch',
                  onTap: _switchCamera,
                ),
                _ControlButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onTap: () => setState(() {
                    _overlayPosition = const Offset(0, 0);
                    _overlayScale = 0.6;
                    _overlayOpacity = 0.85;
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Control Button
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10)),
        ],
      ),
    );
  }
}

// Draws a green dot at each detected body point (debug only)
class _DotsPainter extends CustomPainter {
  final List<Offset> points;
  _DotsPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent;
    for (final p in points) {
      canvas.drawCircle(p, 5, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => true;
}