Barcode Scanner Package

A Flutter package providing a customizable and easy-to-use barcode scanner widget powered by Google ML Kit and Flutter’s camera plugin.
This package supports real-time barcode scanning with options for orientation lock, camera selection, resolution configuration, overlay customization, and performance-optimized frame processing.

Features

Live barcode scanning using the device camera (Google ML Kit)

Supports front and back cameras

Optional orientation lock (portrait or landscape)

Configurable camera resolution

Audio enable/disable

Frame processing throttling to improve performance

Fully customizable scanning overlay:

Mask color

Border color

Border width

Callback with detected barcode value and type

Supports iOS & Android

Example app included

Getting Started
Prerequisites

Flutter SDK 3.x or later

Device with camera capabilities

Google ML Kit dependencies handled automatically

Add necessary permissions:

Android: AndroidManifest.xml

iOS: Info.plist

Installation

Add the package to your pubspec.yaml:

dependencies:
  barcode_scanner: ^0.0.1


Run:

flutter pub get

Usage Example
import 'package:barcode_scanner/barcode_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarcodeScannerScreen(
        orientationLock: DeviceOrientation.portraitUp,
        lensDirection: CameraLensDirection.back,
        resolutionPreset: ResolutionPreset.high,
        enableAudio: false,
        frameProcessingRate: 5,
        overlayColor: const Color.fromRGBO(0, 0, 0, 0.6),
        overlayBorderColor: Colors.green,
        overlayBorderWidth: 3.0,
        onBarcodeDetected: (code, type) {
          debugPrint('Barcode detected: $code, type: $type');
        },
      ),
    );
  }
}


Additional example code can be found in the example/ folder included with the package.

const like = 'vin_scanner';

Additional Information

Visit the GitHub repository for documentation and updates (replace with actual URL).

Contributions are welcome through issues or pull requests.

When reporting issues, include:

Flutter version

Package version

Device model

Clear reproduction steps

Licensed under the MIT License

Advanced users may extend the controller for deeper customization
