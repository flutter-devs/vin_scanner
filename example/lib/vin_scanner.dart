import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vin_scanner/vin_scanner.dart';

/// The main entry point of the application.
void main() => runApp(const MyApp());

/// Root widget of the app.
class MyApp extends StatelessWidget {
  /// Creates the main app widget.
  const MyApp({super.key});

  /// Builds the MaterialApp widget and sets up the barcode scanner screen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BarcodeScannerScreen(
        /// Callback invoked when a barcode is detected.
        onBarcodeDetected: (code, type) {
          debugPrint('Detected barcode: $code');
          debugPrint('Detected barcode type: $type');
        },

        /// Locks the device orientation to portrait mode.
        orientationLock: DeviceOrientation.portraitUp,
      ),
    );
  }
}
