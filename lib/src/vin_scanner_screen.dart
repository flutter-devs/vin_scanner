import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'vin_scanner_controller.dart';
import 'vin_scanner_overlay.dart';

/// A screen widget that displays the camera preview with a barcode scanner overlay.
///
/// This widget manages camera lifecycle, processing barcode scanning in real-time,
/// and optionally locks device orientation during scanning.
class BarcodeScannerScreen extends StatefulWidget {
  /// Optional device orientation lock for the camera capture.
  final DeviceOrientation? orientationLock;

  /// The camera lens direction to use (front or back).
  final CameraLensDirection lensDirection;

  /// Resolution preset for the camera.
  final ResolutionPreset resolutionPreset;

  /// Frame processing rate controls how frequently frames are analyzed.
  final int frameProcessingRate;

  /// Color for the overlay shading outside the scanning box.
  final Color overlayColor;

  /// Color for the border around the scanning box in the overlay.
  final Color overlayBorderColor;

  /// Border width for the scanning box overlay.
  final double overlayBorderWidth;

  /// Callback invoked when a barcode is detected.
  final void Function(String code, BarcodeType type)? onBarcodeDetected;

  /// Whether to start scanning immediately on initialization.
  final bool scanOnInit;

  /// Creates a [BarcodeScannerScreen].
  ///
  /// Default values:
  /// - [lensDirection]: back camera
  /// - [resolutionPreset]: high
  /// - [frameProcessingRate]: 5
  /// - [overlayColor]: semi-transparent black
  /// - [overlayBorderColor]: green
  /// - [overlayBorderWidth]: 3.0
  /// - [scanOnInit]: true
  const BarcodeScannerScreen({
    super.key,
    this.orientationLock,
    this.lensDirection = CameraLensDirection.back,
    this.resolutionPreset = ResolutionPreset.high,
    this.frameProcessingRate = 5,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.6),
    this.overlayBorderColor = Colors.green,
    this.overlayBorderWidth = 3.0,
    this.onBarcodeDetected,
    this.scanOnInit = true,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

/// State class for [BarcodeScannerScreen].
///
/// Handles camera initialization, lifecycle management, and UI rendering.
class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  /// Controller managing camera and barcode scanning operations.
  late final BarcodeScannerController _controller;

  /// Flag indicating whether the camera is ready for preview.
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();

    // Register for app lifecycle events.
    WidgetsBinding.instance.addObserver(this);

    // Lock device orientation to portrait while this screen is active.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Initialize the barcode scanner controller with provided parameters.
    _controller = BarcodeScannerController(
      lensDirection: widget.lensDirection,
      resolutionPreset: widget.resolutionPreset,
      frameProcessingRate: widget.frameProcessingRate,
      onBarcode: (code, type) {
        if (widget.onBarcodeDetected != null) {
          widget.onBarcodeDetected!(code, type);
        }
        setState(() {});
      },
    );

    // Start camera initialization asynchronously.
    _initializeCamera();
  }

  @override
  void dispose() {
    // Remove lifecycle listener and release camera resources.
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();

    // Restore system orientation preferences to all orientations.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  /// Initializes the camera and applies orientation lock if specified.
  Future<void> _initializeCamera() async {
    await _controller.initCamera();

    if (widget.orientationLock != null) {
      await _controller.cameraController!.lockCaptureOrientation(
        widget.orientationLock!,
      );
    }

    setState(() {
      _cameraReady = true;
    });
  }

  /// Handles app lifecycle state changes to properly dispose or reinitialize the camera.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.isInitialized || _controller.cameraController == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller.cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraReady && _controller.isInitialized
          ? Stack(
        children: [
          // Camera preview fills entire screen.
          Positioned.fill(
            child: CameraPreview(_controller.cameraController!),
          ),

          // Overlay with scanning frame and shaded edges.
          BarcodeScannerOverlay(
            overlayColor: widget.overlayColor,
            borderColor: widget.overlayBorderColor,
            borderWidth: widget.overlayBorderWidth,
          ),

          // Display detected barcode value in a fixed-position info box.
          if (_controller.detectedBarcode != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Detected: ${_controller.detectedBarcode!}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
