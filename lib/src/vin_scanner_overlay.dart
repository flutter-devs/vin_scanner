import 'package:flutter/material.dart';

/// A widget displaying an overlay for barcode scanning.
///
/// It shades the surrounding area with a semi-transparent color,
/// highlighting a rectangular scanning area with a colored border.
/// An instruction text is shown below the scanning box.
class BarcodeScannerOverlay extends StatelessWidget {
  /// The color of the shaded overlay outside the scanning area.
  final Color overlayColor;

  /// The color of the rectangular border around the scanning area.
  final Color borderColor;

  /// The thickness of the rectangular border.
  final double borderWidth;

  /// Creates a [BarcodeScannerOverlay].
  ///
  /// Defaults are:
  /// - [overlayColor]: semi-transparent black (0, 0, 0, 0.6)
  /// - [borderColor]: green
  /// - [borderWidth]: 3.0 pixels
  const BarcodeScannerOverlay({
    super.key,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.6),
    this.borderColor = Colors.green,
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Top shaded overlay area (2 flex units)
          Expanded(flex: 2, child: Container(color: overlayColor)),

          // Middle row with left & right shaded sides and scanning box in center
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Row(
              children: [
                // Left shaded overlay (1 flex unit)
                Expanded(flex: 1, child: Container(color: overlayColor)),

                // Scanning area with colored border (4 flex units)
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                  ),
                ),

                // Right shaded overlay (1 flex unit)
                Expanded(flex: 1, child: Container(color: overlayColor)),
              ],
            ),
          ),

          // Bottom shaded overlay with instruction text (2 flex units)
          Expanded(
            flex: 2,
            child: Container(
              color: overlayColor,
              child: const Center(
                child: Text(
                  'Align barcode within frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
