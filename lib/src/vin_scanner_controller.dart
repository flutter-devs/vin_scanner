import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Controller for scanning barcodes using the device camera.
class BarcodeScannerController {
  /// The direction of the camera lens (front or back).
  final CameraLensDirection lensDirection;

  /// The resolution preset for the camera.
  final ResolutionPreset resolutionPreset;

  /// The camera controller instance managing camera operations.
  CameraController? cameraController;

  /// Indicates if the camera has been initialized.
  bool isInitialized = false;

  /// The barcode scanner instance from ML Kit.
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  /// The rate (in frames) at which to process camera frames.
  final int frameProcessingRate;

  /// Counter for processed frames.
  int _frameCounter = 0;

  /// Flag indicating if the image stream is currently being processed.
  bool _isProcessing = false;

  /// The detected barcode value, if any.
  String? detectedBarcode;

  /// Callback function invoked when a barcode is detected.
  final void Function(String code, BarcodeType type)? onBarcode;

  /// Constructs a [BarcodeScannerController].
  ///
  /// [lensDirection] specifies which camera lens to use.
  /// [resolutionPreset] sets the quality of the camera images.
  /// [frameProcessingRate] sets how often frames are processed.
  /// [onBarcode] is called upon successful barcode detection.
  BarcodeScannerController({
    required this.lensDirection,
    this.resolutionPreset = ResolutionPreset.high,
    this.frameProcessingRate = 5,
    this.onBarcode,
  });

  /// Initializes the camera and starts image streaming.
  ///
  /// This method gathers available cameras, selects one based on [lensDirection],
  /// initializes it, and begins streaming images to [processCameraImage].
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
          (c) => c.lensDirection == lensDirection,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      camera,
      resolutionPreset,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.nv21,
    );

    await cameraController!.initialize();

    isInitialized = true;

    await cameraController!.startImageStream(processCameraImage);
  }

  /// Processes each camera image.
  ///
  /// Converts [CameraImage] to [InputImage], detects barcodes,
  /// and triggers [onBarcode] when a barcode is found.
  Future<void> processCameraImage(CameraImage image) async {
    _frameCounter++;
    if (_frameCounter % frameProcessingRate != 0) return;
    if (_isProcessing || detectedBarcode != null) return;

    _isProcessing = true;

    try {
      debugPrint(
        '📸 Processing image: ${image.width}x${image.height}, format: ${image.format.raw}',
      );
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        debugPrint('❌ Failed to build InputImage');
        _isProcessing = false;
        return;
      }

      final barcodes = await _barcodeScanner.processImage(inputImage);
      debugPrint('📊 Found ${barcodes.length} barcodes');

      if (barcodes.isNotEmpty && detectedBarcode == null) {
        final barcode = barcodes.first;
        final code = barcode.rawValue ?? '';

        if (code.isNotEmpty) {
          debugPrint('✅ Valid barcode found: $code');
          await cameraController!.stopImageStream();
          detectedBarcode = code;
          if (onBarcode != null) onBarcode!(code, barcode.type);
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Builds an [InputImage] from [CameraImage].
  ///
  /// Converts raw camera data into a format suitable for ML Kit processing.
  InputImage? _buildInputImage(CameraImage image) {
    try {
      final camera = cameraController!.description;

      final sensorOrientation = camera.sensorOrientation;
      final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);

      if (rotation == null) {
        debugPrint('❌ Could not determine rotation');
        return null;
      }

      InputImageFormat? format;
      if (Platform.isIOS) {
        if (image.format.raw == 1111970369) {
          format = InputImageFormat.bgra8888;
        } else {
          format = InputImageFormatValue.fromRawValue(image.format.raw);
        }
      } else {
        format = InputImageFormatValue.fromRawValue(image.format.raw);
      }

      if (format == null) {
        debugPrint('❌ Unsupported format: ${image.format.raw}');
        return null;
      }

      final bytes = image.planes.first.bytes;

      return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    format: format,
    bytesPerRow: image.planes.first.bytesPerRow,
    ),
    );
    } catch (e) {
    debugPrint('❌ Error building InputImage: $e');
    return null;
    }
  }

  /// Releases resources used by the scanner and camera.
  void dispose() {
    _barcodeScanner.close();
    cameraController?.dispose();
  }
}
