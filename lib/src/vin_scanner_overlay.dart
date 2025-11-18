import 'package:flutter/material.dart';

class BarcodeScannerOverlay extends StatelessWidget {
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

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
          Expanded(flex: 2, child: Container(color: overlayColor)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Row(
              children: [
                Expanded(flex: 1, child: Container(color: overlayColor)),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: borderWidth),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Container(color: overlayColor)),
              ],
            ),
          ),
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
