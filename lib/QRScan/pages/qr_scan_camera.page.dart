import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../example.dart';

class QrScanCameraPage extends StatefulWidget {
  const QrScanCameraPage({super.key});
  static const routeName = '/QrScanCameraPage';

  @override
  State<QrScanCameraPage> createState() => _QrScanCameraPageState();
}

class _QrScanCameraPageState extends State<QrScanCameraPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScan');
  Barcode? result;
  QRViewController? QRcontroller;

  void resemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      QRcontroller!.pauseCamera();
    } else if (Platform.isIOS) {
      QRcontroller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 400,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
              overlay: QrScannerOverlayShape(),
            ),
          ),
        ],
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    QRcontroller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
        controller.pauseCamera();
        final String qrCode = event.code.toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultQrPage(resultQr: qrCode),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    QRcontroller?.dispose();
  }
}
