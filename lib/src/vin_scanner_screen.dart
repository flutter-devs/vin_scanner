import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'vin_scanner_controller.dart';
import 'vin_scanner_overlay.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final DeviceOrientation? orientationLock;
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;
  final int frameProcessingRate;

  final Color overlayColor;
  final Color overlayBorderColor;
  final double overlayBorderWidth;

  final void Function(String code, BarcodeType type)? onBarcodeDetected;
  final bool scanOnInit;

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

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  late final BarcodeScannerController _controller;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

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
                Positioned.fill(
                  child: CameraPreview(_controller.cameraController!),
                ),
                BarcodeScannerOverlay(
                  overlayColor: widget.overlayColor,
                  borderColor: widget.overlayBorderColor,
                  borderWidth: widget.overlayBorderWidth,
                ),
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
