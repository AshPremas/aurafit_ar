import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/ar_service.dart';
import '../../services/wishlist_service.dart';

/// TryOnScreen — Core AR virtual fitting room screen.
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
  bool _isARActive = false;
  bool _isProcessing = false;
  String _statusMessage = 'Tap "Try-on" to start';
  PoseLandmarks? _landmarks;

  //Activate AR and start pose detection 
  Future<void> _startARSession() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Initialising camera...';
    });

    // Request camera permission and initialise ARCore session
    final bool cameraReady = await ARService.instance.initCamera();
    if (!cameraReady) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Camera permission denied';
      });
      return;
    }

    setState(() => _statusMessage = 'Detecting body landmarks...');

    // Run MediaPipe Pose estimation and return detected landmarks
    final landmarks = await ARService.instance.detectPoseLandmarks();

    setState(() {
      _landmarks = landmarks;
      _isARActive = true;
      _isProcessing = false;
      _statusMessage = landmarks != null
          ? 'Body detected — overlay active'
          : 'Could not detect body. Adjust position.';
    });
  }

  // ── Capture screenshot of the current AR frame ────────────────────────────
  Future<void> _captureScreenshot() async {
    await ARService.instance.captureFrame();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screenshot saved to gallery'),
          backgroundColor: kAccentColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    ARService.instance.disposeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildTopBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraFeed(),
          if (_isARActive && _landmarks != null) _buildGarmentOverlay(),
          _buildStatusOverlay(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Try-on',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ── Simulated Camera Feed ─────────────────────────────────────────────────
  // In production: replaced by a CameraPreview widget fed by ARCore session.
  Widget _buildCameraFeed() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isARActive ? Icons.camera_alt : Icons.camera_alt_outlined,
              color: Colors.white54,
              size: 80,
            ),
            const SizedBox(height: 12),
            Text(
              _isARActive
                  ? 'Camera Feed Active'
                  : 'Virtual Try-On Feed\n(AR/Camera View)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Garment Overlay ───────────────────────────────────────────────────────
  // Positioned and scaled based on detected body landmarks.
  // In production: ARCore positions the PNG precisely on the body.
  Widget _buildGarmentOverlay() {
    return Center(
      child: Opacity(
        opacity: 0.85,
        child: Container(
          width: (_landmarks?.shoulderWidthPx ?? 200) * 1.4,
          height: (_landmarks?.torsoHeightPx ?? 300) * 1.2,
          decoration: BoxDecoration(
            color: kAccentColor.withOpacity(0.2),
            border: Border.all(color: kAccentColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.checkroom, color: kAccentColor, size: 80),
              const SizedBox(height: 8),
              Text(
                widget.item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'Size: ${widget.selectedSize}',
                style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Message Overlay ────────────────────────────────────────────────
  Widget _buildStatusOverlay() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _isProcessing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kAccentColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_statusMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                )
              : Text(_statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }

  // ── Bottom Control Buttons ────────────────────────────────────────────────
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Try-on activation button
            if (!_isARActive)
              SizedBox(
                width: 160,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _startARSession,
                  style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
                  child: const Text(
                    'Try-on',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Screenshot / Wishlist / Switch camera row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.camera_alt,
                  label: 'Take\nScreenshot',
                  onTap: _captureScreenshot,
                ),
                _ControlButton(
                  icon: Icons.favorite,
                  label: 'Save to\nWishlist',
                  onTap: () {
                    WishlistService.instance.addItem(widget.item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.item.name} saved to wishlist'),
                        backgroundColor: kAccentColor,
                      ),
                    );
                  },
                ),
                _ControlButton(
                  icon: Icons.switch_camera,
                  label: 'Switch',
                  onTap: ARService.instance.switchCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Control Button ─────────────────────────────────────────────────
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
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
