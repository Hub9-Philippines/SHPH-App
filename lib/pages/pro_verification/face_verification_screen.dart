import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '/api/resources/kyc_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/components/screen_header.dart';
import '/index.dart';
import '/services/kyc_submission_service.dart';
import '/theme/app_theme.dart';

enum VerificationState {
  initial,
  preview,
  review,
  uploading,
  success,
  failed,
}

/// Default plan used when the server liveness challenge cannot be fetched.
const List<String> kLocalLivenessPlan = ['centerFace', 'blink', 'smile'];

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({
    Key? key,
    this.onVerificationComplete,
    this.onVerificationFailed,
    this.userId,
  }) : super(key: key);

  static String routeName = 'FaceVerification';
  static String routePath = '/face-verification';

  final Function(String imagePath)? onVerificationComplete;
  final VoidCallback? onVerificationFailed;
  final String? userId;

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  VerificationState _state = VerificationState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  List<CameraDescription> _cameras = [];
  String? _capturedImagePath;
  bool _faceDetected = false;
  bool _isCapturing = false;

  final KycSubmissionService _kyc = KycSubmissionService.instance;

  // Server-issued liveness challenge state.
  List<String> _plan = [];
  String? _nonce;
  int _completedActions = 0;
  double? _livenessScore;
  Map<String, dynamic> _livenessMetadata = {};

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  String? get _currentAction =>
      _completedActions < _plan.length ? _plan[_completedActions] : null;

  bool get _isLivenessComplete =>
      _plan.isNotEmpty && _completedActions >= _plan.length;

  /// Request the server liveness challenge; fall back to the local plan when
  /// the API is unavailable (web parity: server plan drives the sequence).
  Future<void> _loadLivenessPlan() async {
    try {
      final challenge = await ShphKycApi.instance.requestLivenessChallenge();
      final plan = (challenge['plan'] as List?)
          ?.map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
      _nonce = challenge['nonce'] as String?;
      if (plan != null && plan.isNotEmpty) {
        _plan = plan;
        return;
      }
    } catch (e) {
      // Fall through to the local plan.
    }
    _plan = List.of(kLocalLivenessPlan);
    _nonce = null;
  }

  Future<void> _startVerification() async {
    setState(() {
      _isLoading = true;
      _state = VerificationState.preview;
    });

    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
      await _faceDetector?.close();
      _faceDetector = null;

      await _loadLivenessPlan();
      _completedActions = 0;
      _livenessScore = null;
      _livenessMetadata = {};

      await Future.delayed(const Duration(milliseconds: 300));

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _state = VerificationState.failed;
          _errorMessage = 'No camera available on this device.';
          _isLoading = false;
        });
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      _processCameraFrames();

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

  bool _actionSatisfied(String action, Face face) {
    final rect = face.boundingBox;
    switch (action) {
      case 'centerFace':
        final horizontalCenter = rect.center.dx;
        final inMiddleThird = horizontalCenter > 90 && horizontalCenter < 210;
        final largeEnough = rect.width >= 120;
        return inMiddleThird && largeEnough;
      case 'blink':
        final leftClosed =
            (face.leftEyeOpenProbability ?? 0.0) < 0.3;
        final rightClosed =
            (face.rightEyeOpenProbability ?? 0.0) < 0.3;
        return leftClosed && rightClosed;
      case 'smile':
        return (face.smilingProbability ?? 0.0) > 0.6;
      case 'turnLeft':
        return (face.headEulerAngleY ?? 0.0) < -15;
      case 'turnRight':
        return (face.headEulerAngleY ?? 0.0) > 15;
      default:
        return true;
    }
  }

  Future<void> _detectFace(String imagePath) async {
    if (_faceDetector == null) return;

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (!mounted || _state != VerificationState.preview) return;

      if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
        });
        return;
      }

      final face = faces.first;
      setState(() {
        _faceDetected = true;
      });

      // Advance through the plan: satisfy the current action to move on.
      final action = _currentAction;
      if (action != null && !_isLivenessComplete) {
        if (_actionSatisfied(action, face)) {
          _completedActions++;
          _livenessMetadata['$action'] = true;
          setState(() {});
          if (_isLivenessComplete) {
            _livenessScore = 1.0;
          }
        }
      }
    } catch (e) {
      // Ignore detection errors
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing || _cameraController!.value.isTakingPicture) {
      return;
    }

    setState(() => _isCapturing = true);

    await Future.delayed(const Duration(milliseconds: 50));

    const maxRetries = 5;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final image = await _cameraController!.takePicture();

        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'face_verification_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${directory.path}/$fileName');
        await File(image.path).copy(savedImage.path);

        await _cameraController?.dispose();
        _cameraController = null;

        // Persist selfie + liveness result only in the in-memory submission
        // state (never SharedPreferences) — the backend is the source of truth.
        final bytes = await savedImage.readAsBytes();
        _kyc.setLivenessResult(
          nonce: _nonce,
          plan: _plan,
          decision: 'pass',
          score: _livenessScore,
          metadata: {
            ..._livenessMetadata,
            'completed_actions': _plan,
            'completed_at': DateTime.now().toIso8601String(),
            'engine': 'google_mlkit_face_detection',
          },
          selfie: KycDocumentFile(bytes, 'selfie.jpg'),
        );

        setState(() {
          _capturedImagePath = savedImage.path;
          _state = VerificationState.review;
          _isCapturing = false;
        });
        return;
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
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_capturedImagePath == null) {
      _showError('No image captured');
      return;
    }

    setState(() => _state = VerificationState.uploading);

    try {
      if (!_kyc.hasRequiredDocuments) {
        throw Exception('Missing required documents. Go back and upload them.');
      }
      if (_kyc.isLivenessBlocked) {
        _resetLivenessForRetry();
        throw Exception('Liveness verification did not pass. Please redo the face check.');
      }

      await _kyc.submit();

      widget.onVerificationComplete?.call(_capturedImagePath!);

      if (mounted) {
        context.goNamed(VerificationReviewingWidget.routeName);
      }
    } catch (e) {
      // A rejected/expired liveness challenge means the stored nonce is dead —
      // reset liveness and ask the user to redo the face check.
      final msg = e.toString().toLowerCase();
      if (msg.contains('liveness') || msg.contains('challenge')) {
        _resetLivenessForRetry();
      }
      setState(() {
        _state = VerificationState.failed;
        _errorMessage = e.toString();
      });
    }
  }

  void _resetLivenessForRetry() {
    _kyc.resetLiveness();
    _plan = [];
    _nonce = null;
    _completedActions = 0;
    _livenessScore = null;
    _livenessMetadata = {};
    _capturedImagePath = null;
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _faceDetected = false;
      _state = VerificationState.initial;
    });
    _startVerification();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Face Verification',
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      );

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

  Widget _buildStartView() {
    final theme = AppTheme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.19),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_rounded,
                color: theme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Face Verification',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'We need to take a photo of your face to verify your identity. Follow the on-screen actions to complete the liveness check.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
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
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String text) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: theme.secondaryText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: theme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _currentActionLabel {
    switch (_currentAction) {
      case 'centerFace':
        return 'Center your face in the frame';
      case 'blink':
        return 'Blink your eyes';
      case 'smile':
        return 'Smile';
      case 'turnLeft':
        return 'Turn your head to the left';
      case 'turnRight':
        return 'Turn your head to the right';
      default:
        return 'Position your face within the circle';
    }
  }

  Widget _buildLoadingView() {
    final theme = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: GoogleFonts.plusJakartaSans(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final theme = AppTheme.of(context);
    return Column(
      children: [
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
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _faceDetected
                          ? theme.success
                          : theme.primaryBackground,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(125),
                  ),
                  child: Center(
                    child: _faceDetected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.success,
                            size: 60,
                          )
                        : Icon(
                            Icons.face,
                            color:
                                theme.primaryBackground.withValues(alpha: 0.7),
                            size: 60,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            color: theme.primaryBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLivenessComplete
                      ? 'Liveness check passed! Ready to capture'
                      : _faceDetected
                          ? _currentActionLabel
                          : 'Position your face within the circle',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isLivenessComplete
                        ? theme.success
                        : theme.primaryText,
                  ),
                ),
                if (_plan.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_completedActions} of ${_plan.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    ElevatedButton.icon(
                      onPressed:
                          _isCapturing || !_isLivenessComplete ? null : _capturePhoto,
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
                        backgroundColor:
                            _isLivenessComplete ? theme.success : theme.primary,
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
  }

  Widget _buildReviewView() {
    final theme = AppTheme.of(context);
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _capturedImagePath != null &&
                  File(_capturedImagePath!).existsSync()
              ? Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Center(
                  child: Text(
                    'Image not found',
                    style:
                        GoogleFonts.plusJakartaSans(color: theme.secondaryText),
                  ),
                ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            color: theme.primaryBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility,
                          color: theme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Review Photo',
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.primary,
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
                    OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _submitVerification,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.success,
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
  }

  Widget _buildUploadingView() {
    final theme = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Uploading verification...',
            style: GoogleFonts.plusJakartaSans(color: theme.primaryText),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait',
            style: GoogleFonts.plusJakartaSans(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final theme = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: theme.success),
          const SizedBox(height: 24),
          Text(
            'Verification Submitted!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Redirecting to status page...',
            style: GoogleFonts.plusJakartaSans(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedView() {
    final theme = AppTheme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: theme.error),
            const SizedBox(height: 24),
            Text(
              'Verification Failed',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.error,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.plusJakartaSans(color: theme.secondaryText),
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.plusJakartaSans(color: theme.primaryText),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                    _startVerification();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

typedef FaceVerifyWidget = FaceVerificationScreen;
