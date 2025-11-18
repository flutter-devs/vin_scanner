import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerController {
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;

  CameraController? cameraController;
  bool isInitialized = false;

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  final int frameProcessingRate;

  int _frameCounter = 0;
  bool _isProcessing = false;

  String? detectedBarcode;
  final void Function(String code, BarcodeType type)? onBarcode;

  BarcodeScannerController({
    required this.lensDirection,
    this.resolutionPreset = ResolutionPreset.high,
    this.frameProcessingRate = 5,
    this.onBarcode,
  });

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

  void dispose() {
    _barcodeScanner.close();
    cameraController?.dispose();
  }
}
