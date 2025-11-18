import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vin_scanner/vin_scanner.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BarcodeScannerScreen(
        onBarcodeDetected: (code, type) {
          debugPrint('Detected barcode: $code');
          debugPrint('Detected barcode type: $type');
        },
        orientationLock: DeviceOrientation.portraitUp,
      ),
    );
  }
}
