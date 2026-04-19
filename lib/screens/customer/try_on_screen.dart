import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/wishlist_service.dart';

/// TryOnScreen — Real camera feed with garment overlay.
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
  int _selectedCameraIndex = 1; // Start with front camera
  String _statusMessage = 'Initializing camera...';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // ── Initialize Camera ─────────────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _statusMessage = 'No camera found on device';
          _isLoading = false;
        });
        return;
      }

      // Use front camera by default (index 1)
      // Fall back to rear camera (index 0) if front not available
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

  // ── Start Camera ──────────────────────────────────────────────────────────
  Future<void> _startCamera(int cameraIndex) async {
    final camera = _cameras[cameraIndex];

    _cameraController = CameraController(
      camera,
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

  // ── Switch Camera ─────────────────────────────────────────────────────────
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() => _isLoading = true);
    await _cameraController?.dispose();

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras.length;

    await _startCamera(_selectedCameraIndex);
  }

  // ── Toggle Garment Overlay ────────────────────────────────────────────────
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      _statusMessage = _showOverlay
          ? 'Garment overlay active'
          : 'Tap "Try-on" to overlay garment';
    });
  }

  // ── Capture Screenshot ────────────────────────────────────────────────────
  Future<void> _captureScreenshot() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot saved: ${image.path}'),
            backgroundColor: kAccentColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screenshot failed: $e'),
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
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Feed ──────────────────────────────────────────────
          _buildCameraFeed(),

          // ── Garment Overlay ──────────────────────────────────────────
          if (_showOverlay && _isCameraInitialized)
            _buildGarmentOverlay(),

          // ── Status Message ───────────────────────────────────────────
          _buildStatusOverlay(),

          // ── Bottom Controls ──────────────────────────────────────────
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Try-on',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ── Camera Feed ───────────────────────────────────────────────────────────
  Widget _buildCameraFeed() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kAccentColor),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Text(
          _statusMessage,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  // ── Garment Overlay ───────────────────────────────────────────────────────
  Widget _buildGarmentOverlay() {
    return Center(
      child: Opacity(
        opacity: 0.75,
        child: Image.asset(
          widget.item.arOverlayAsset,
          width: MediaQuery.of(context).size.width * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Status Overlay ────────────────────────────────────────────────────────
  Widget _buildStatusOverlay() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusMessage,
            style: const TextStyle(
                color: Colors.white, fontSize: 12),
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
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8)
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Try-on button
            SizedBox(
              width: 160,
              height: 50,
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
            const SizedBox(height: 12),
            // Control buttons row
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
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            '${widget.item.name} saved!'),
                        backgroundColor: kAccentColor,
                      ),
                    );
                  },
                ),
                _ControlButton(
                  icon: Icons.switch_camera,
                  label: 'Switch',
                  onTap: _switchCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Control Button Widget ────────────────────────────────────────────────────
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}