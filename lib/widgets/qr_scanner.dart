import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/custom_snackbar.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Scan QR Code",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // body: MobileScanner(
      //   onDetect: (capture) {
      //     final List<Barcode> barcodes = capture.barcodes;
      //     if (barcodes.isNotEmpty) {
      //       final String? code = barcodes.first.rawValue;
      //       if (code != null) {
      //         Navigator.pop(context);
      //         CustomSnackbar.show(
      //           title: "Scanned Successfully",
      //           message: "QR Code: $code",
      //           isSuccess: true,
      //         );
      //       }
      //     }
      //   },
      // ),
    );
  }
}
