<!Barcode Scanner Package
A Flutter package providing a customizable, easy-to-use barcode scanner widget powered by Google ML Kit and Flutter’s camera plugin. This package supports live camera feed barcode scanning with flexible configuration options such as camera orientation lock, resolution presets, overlay styling, and frame processing rate. It is ideal for developers looking to quickly integrate barcode scanning features into their Flutter apps with robust performance and clean UI.

## Features

    •	Live barcode scanning using device camera with Google ML Kit integration
	•	Supports front and back cameras (configurable)
	•	Orientation lock option for portrait or landscape modes
	•	Adjustable camera resolution and audio enable/disable
	•	Frame processing throttling to optimize performance
	•	Customizable scanning overlay with configurable mask color, border color, and border width
	•	Callback for detected barcode data including barcode type
	•	Supports iOS and Android platforms with native image processing formats handled
	•	Example app included demonstrating package usage


## Getting started

Prerequisites

    •	Flutter SDK installed (version 3.x or later recommended)
	•	Device with camera support (real devices preferred for scanning)
	•	Google ML Kit dependencies handled automatically by the package
	•	Add required app permissions for camera usage in AndroidManifest.xml (Android) and Info.plist (iOS).

Installation

Add this package to your  pubspec.yaml  dependencies:

    dependencies: 
      barcode_scanner: ^0.0.1

Run  flutter pub get  to install the package.

## Usage

Import the package and use the ready-to-use  BarcodeScannerScreen  widget:

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

Longer and more detailed examples are available in the  /example  folder provided with the package.


```dart
const like = 'vin_scanner';
```

## Additional information

For more info, visit the GitHub repository (replace with actual URL).
	•	Contributions are welcome via pull requests or issues opened on GitHub.
	•	When filing issues, please include Flutter and package versions, device details, and reproduction steps.
	•	This package is licensed under the MIT License. See the LICENSE file for details.
	•	For updates, changelog, and release notes, refer to the  CHANGELOG.md  file.
	•	If you want to customize barcode detection further, consider extending the controller or contributing features.