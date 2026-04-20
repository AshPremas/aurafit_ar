import 'dart:async';

/// PoseLandmarks
class PoseLandmarks {
  /// Pixel distance between left and right shoulder landmarks.
  final double shoulderWidthPx;

  /// Pixel distance between left and right hip landmarks.
  final double hipWidthPx;

  /// Pixel distance from shoulder midpoint to hip midpoint (torso height).
  final double torsoHeightPx;

  /// Normalised [0.0–1.0] x-coordinate of the shoulder midpoint.
  final double shoulderMidX;

  /// Normalised [0.0–1.0] y-coordinate of the shoulder midpoint.
  final double shoulderMidY;

  const PoseLandmarks({
    required this.shoulderWidthPx,
    required this.hipWidthPx,
    required this.torsoHeightPx,
    required this.shoulderMidX,
    required this.shoulderMidY,
  });
}

/// ARService — Singleton service layer that abstracts the interaction
class ARService {
  ARService._internal();
  static final ARService instance = ARService._internal();

  bool _cameraInitialised = false;
  bool _useFrontCamera = true;

  // Camera Initialisation 
  /// Requests camera permission and initialises the ARCore session.
  /// Returns [true] if camera is ready, [false] if permission is denied.
  Future<bool> initCamera() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulated delay
    _cameraInitialised = true;
    return true;
  }

  // MediaPipe Pose Landmark Detection
  /// Returns [null] if no body is detected in the frame.
  Future<PoseLandmarks?> detectPoseLandmarks() async {
    if (!_cameraInitialised) return null;

    await Future.delayed(const Duration(milliseconds: 1200)); // Simulated delay

    // Mock landmarks based on a typical front-facing camera frame
    // (320px wide, 480px tall reference frame)
    return const PoseLandmarks(
      shoulderWidthPx: 180.0,
      hipWidthPx: 160.0,
      torsoHeightPx: 220.0,
      shoulderMidX: 0.50,
      shoulderMidY: 0.28,
    );
  }

  /// Calculates the garment overlay dimensions from pose landmarks.
  /// Width = 120% shoulder width
  /// Height = 130% torso height
  Map<String, double> calculateGarmentDimensions(PoseLandmarks landmarks) {
    return {
      'width': landmarks.shoulderWidthPx * 1.2,
      'height': landmarks.torsoHeightPx * 1.3,
      'offsetX': landmarks.shoulderMidX,
      'offsetY': landmarks.shoulderMidY,
    };
  }

  // Frame Capture
  /// Captures the current AR composite frame (camera + garment overlay)
  /// and saves it to the device gallery.
  Future<void> captureFrame() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Camera Switch
  /// Toggles between front and rear camera.
  Future<void> switchCamera() async {
    _useFrontCamera = !_useFrontCamera;
    await initCamera();
  }

  // Session Cleanup
  void disposeSession() {
    _cameraInitialised = false;
  }
}
