import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/services/profiles_service.dart';
import '../../services/face_verification/face_verification_service.dart';

/// Enum representing the states of the face verification process
enum VerificationState {
  /// Initial state - waiting for user to start
  initial,

  /// Camera preview active, ready to capture
  preview,

  /// Captured image ready for review
  review,

  /// Uploading to server
  uploading,

  /// All completed successfully
  success,

  /// Verification failed or was cancelled
  failed,
}

/// Production-ready face verification widget
///
/// Flow:
/// 1. Start screen - user clicks "Start Verification"
/// 2. Camera preview - shows face detection overlay, user clicks capture
/// 3. Review screen - user reviews photo, clicks submit
/// 4. Upload and navigate to VerificationReviewingWidget
class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({
    Key? key,
    this.onVerificationComplete,
    this.onVerificationFailed,
    this.userId,
  }) : super(key: key);

  /// Route name for navigation
  static String routeName = 'FaceVerification';

  /// Route path for navigation
  static String routePath = '/face-verification';

  /// Callback when verification completes successfully
  final Function(String imagePath)? onVerificationComplete;

  /// Callback when verification fails or is cancelled
  final VoidCallback? onVerificationFailed;

  /// User ID for storing verification status
  final String? userId;

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  /// Current state of the verification process
  VerificationState _state = VerificationState.initial;

  /// Error message to display when verification fails
  String? _errorMessage;

  /// Loading state while initializing
  bool _isLoading = false;

  /// Camera controller
  CameraController? _cameraController;

  /// Face detector
  FaceDetector? _faceDetector;

  /// List of available cameras
  List<CameraDescription> _cameras = [];

  /// Captured image path
  String? _capturedImagePath;

  /// Whether a face is currently detected
  bool _faceDetected = false;
  Map<String, dynamic>? _livenessChallenge;

  /// Whether capture is in progress (prevents double-tap)
  bool _isCapturing = false;

  /// Face verification service
  final FaceVerificationService _faceVerificationService =
      FaceVerificationService();

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  /// Initialize camera and face detector when user starts
  Future<void> _startVerification() async {
    setState(() {
      _isLoading = true;
      _state = VerificationState.preview;
    });

    try {
      _livenessChallenge = await ShphKycApi.instance.createLivenessChallenge();

      // Clean up any existing camera controller first
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      await _faceDetector?.close();
      _faceDetector = null;

      // Small delay to ensure camera is fully released
      await Future.delayed(const Duration(milliseconds: 300));

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _state = VerificationState.failed;
          _errorMessage = 'No camera available on this device.';
          _isLoading = false;
        });
        return;
      }

      // Find front camera
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      // Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Initialize face detector
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      // Start face detection
      _startFaceDetection();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _state = VerificationState.failed;
        _errorMessage = 'Failed to initialize camera: $e';
        _isLoading = false;
      });
    }
  }

  /// Start continuous face detection
  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _processCameraFrames();
  }

  /// Process camera frames to detect faces
  Future<void> _processCameraFrames() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      while (mounted &&
          _state == VerificationState.preview &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted || _state != VerificationState.preview) break;

        try {
          final image = await _cameraController!.takePicture();
          await _detectFace(image.path);
          // Delete temporary image
          try {
            File(image.path).deleteSync();
          } catch (_) {}
        } catch (e) {
          // Ignore capture errors during streaming
        }
      }
    } catch (e) {
      // Stop processing on error
    }
  }

  /// Detect face in captured image
  Future<void> _detectFace(String imagePath) async {
    if (_faceDetector == null) return;

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (mounted) {
        setState(() {
          _faceDetected = faces.isNotEmpty;
        });
      }
    } catch (e) {
      // Ignore detection errors
    }
  }

  /// Capture photo manually with retry logic
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // Prevent multiple simultaneous captures - check both flag and controller state
    if (_isCapturing || _cameraController!.value.isTakingPicture) {
      return;
    }

    // Set flag immediately before any async operations and update UI
    setState(() => _isCapturing = true);

    // Small delay to ensure UI updates before camera operation
    await Future.delayed(const Duration(milliseconds: 50));

    const maxRetries = 5;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final image = await _cameraController!.takePicture();

        // Save to app directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'face_verification_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${directory.path}/$fileName');
        await File(image.path).copy(savedImage.path);

        // Stop camera
        await _cameraController?.dispose();
        _cameraController = null;

        setState(() {
          _capturedImagePath = savedImage.path;
          _state = VerificationState.review;
          _isCapturing = false;
        });
        return; // Success - exit the retry loop
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          setState(() {
            _errorMessage =
                'Failed to capture image after $maxRetries attempts: $e';
            _state = VerificationState.failed;
            _isCapturing = false;
          });
          return;
        }
        // Wait a short delay before retrying
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  /// Submit verification - upload and navigate to progress page
  Future<void> _submitVerification() async {
    if (_capturedImagePath == null) {
      _showError('No image captured');
      return;
    }

    setState(() => _state = VerificationState.uploading);

    try {
      final me = await ShphUsersApi.instance.getMe();
      final userId = widget.userId ?? me['id']?.toString();
      if (userId == null) throw Exception('User not authenticated');

      // Upload through the authenticated profile API.
      final file = File(_capturedImagePath!);
      final fileBytes = await file.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_face_verification.jpg';

      final imageUrl = await ProfilesService.instance
          .uploadProfilePhoto(fileBytes, fileName);

      // Update profile with face scan URL and pending status
      await ProfilesService.instance.updateProfile({
        'face_scan_url': imageUrl,
        'verification_status': 'reviewing',
        'face_scan_submitted_at': DateTime.now().toIso8601String(),
      });

      // Mark as verified in local service
      await _faceVerificationService.markAsVerified(userId);

      // Invoke callback
      widget.onVerificationComplete?.call(_capturedImagePath!);

      if (mounted) {
        // Navigate to verification in progress page
        context.goNamed('VerificationReviewing');
      }
    } catch (e) {
      setState(() {
        _state = VerificationState.failed;
        _errorMessage = 'Upload failed: $e';
      });
    }
  }

  /// Retake photo - go back to camera preview
  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _faceDetected = false;
      _state = VerificationState.initial;
    });
    _startVerification();
  }

  /// Show error snackbar
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Face Verification'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _buildBody(),
      );

  /// Builds the main body content based on current state
  Widget _buildBody() {
    switch (_state) {
      case VerificationState.initial:
        return _buildStartView();
      case VerificationState.preview:
        return _isLoading ? _buildLoadingView() : _buildCameraPreview();
      case VerificationState.review:
        return _buildReviewView();
      case VerificationState.uploading:
        return _buildUploadingView();
      case VerificationState.success:
        return _buildSuccessView();
      case VerificationState.failed:
        return _buildFailedView();
    }
  }

  /// Start view - user clicks button to begin
  Widget _buildStartView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0x31368EFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.face_rounded,
                color: Color(0xFF368EFF),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Face Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'We need to take a photo of your face to verify your identity. Please ensure you are in a well-lit area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            _buildRequirementItem(Icons.lightbulb, 'Ensure good lighting'),
            _buildRequirementItem(
                Icons.remove_circle, 'Remove glasses or masks'),
            _buildRequirementItem(
                Icons.center_focus_strong, 'Center your face in the frame'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startVerification,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Verification'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );

  Widget _buildRequirementItem(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );

  /// Loading view
  Widget _buildLoadingView() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );

  /// Camera preview with capture button
  Widget _buildCameraPreview() => Column(
        children: [
          // Camera preview area
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_cameraController != null &&
                    _cameraController!.value.isInitialized)
                  CameraPreview(_cameraController!)
                else
                  const Center(child: CircularProgressIndicator()),

                // Face detection overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _faceDetected ? Colors.green : Colors.white,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(125),
                    ),
                    child: Center(
                      child: _faceDetected
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 60,
                            )
                          : const Icon(
                              Icons.face,
                              color: Colors.white70,
                              size: 60,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _faceDetected
                        ? 'Face detected! Ready to capture'
                        : 'Position your face within the circle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _faceDetected ? Colors.green : Colors.black87,
                    ),
                  ),
                  if (_livenessChallenge != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      (_livenessChallenge!['instruction'] ??
                              _livenessChallenge!['action'] ??
                              'Follow the requested movement before capture')
                          .toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      TextButton.icon(
                        onPressed: () {
                          _cameraController?.dispose();
                          setState(() {
                            _state = VerificationState.initial;
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                      ),
                      const SizedBox(width: 24),
                      // Capture button
                      ElevatedButton.icon(
                        onPressed: _isCapturing ? null : _capturePhoto,
                        icon: _isCapturing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera),
                        label: Text(_isCapturing ? 'Capturing...' : 'Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _faceDetected
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  /// Review captured photo
  Widget _buildReviewView() => Column(
        children: [
          // Preview
          Expanded(
            flex: 3,
            child: _capturedImagePath != null &&
                    File(_capturedImagePath!).existsSync()
                ? Image.file(
                    File(_capturedImagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : const Center(child: Text('Image not found')),
          ),

          // Controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x2D368EFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility,
                            color: Color(0xFF368EFF), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Review Photo',
                          style: TextStyle(
                            color: Color(0xFF368EFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Retake button
                      OutlinedButton.icon(
                        onPressed: _retakePhoto,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Submit button
                      ElevatedButton.icon(
                        onPressed: _submitVerification,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  /// Uploading view
  Widget _buildUploadingView() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading verification...'),
            SizedBox(height: 8),
            Text(
              'Please wait',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );

  /// Success view
  Widget _buildSuccessView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Verification Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Redirecting to status page...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );

  /// Failed view
  Widget _buildFailedView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Verification Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                    // Directly restart verification
                    _startVerification();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      );
}

/// Alias for FaceVerificationScreen to maintain compatibility with router naming
typedef FaceVerifyWidget = FaceVerificationScreen;
