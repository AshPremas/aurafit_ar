import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/wishlist_service.dart';

class TryOnScreen extends StatefulWidget {
  final ClothingItem item;
  final String selectedSize;

  const TryOnScreen({
    super.key,
    required this.item,
    required this.selectedSize,
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

  // ── Overlay Controls ───────────────────────────────────────────────────
  double _overlayScale = 0.6;      // Zoom: 0.2 to 1.0
  double _overlayOpacity = 0.85;   // Opacity: 0.3 to 1.0
  Offset _overlayPosition = const Offset(0, 0); // Drag position
  Offset _dragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
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
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
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

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isLoading = true);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Feed ────────────────────────────────────────────
          _buildCameraFeed(),

          // ── Draggable Garment Overlay ──────────────────────────────
          if (_showOverlay && _isCameraInitialized)
            _buildDraggableOverlay(),

          // ── Top Bar ────────────────────────────────────────────────
          _buildTopBar(),

          // ── Status Message ─────────────────────────────────────────
          _buildStatusOverlay(),

          // ── Bottom Controls ────────────────────────────────────────
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
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

  // ── Camera Feed ───────────────────────────────────────────────────────────
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

  // ── Draggable Garment Overlay ─────────────────────────────────────────────
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
        // ── Drag to reposition ──────────────────────────────────────
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
          child: Image.asset(
            widget.item.arOverlayAsset,
            width: screenSize.width * _overlayScale,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // ── Status Overlay ────────────────────────────────────────────────────────
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

  // ── Bottom Controls ───────────────────────────────────────────────────────
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

            // ── Zoom Slider ──────────────────────────────────────────
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

              // ── Opacity Slider ─────────────────────────────────────
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

            // ── Try-on Button ────────────────────────────────────────
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

            // ── Icon Buttons Row ─────────────────────────────────────
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
                  onTap: () {
                    WishlistService.instance
                        .addItem(widget.item);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                      content: Text(
                          '${widget.item.name} saved!'),
                      backgroundColor: kAccentColor,
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

// ─── Control Button ───────────────────────────────────────────────────────────
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