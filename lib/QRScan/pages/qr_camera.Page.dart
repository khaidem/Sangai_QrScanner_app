import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../core/helper/logger.dart';
import '../logic/qr_scan.provider.dart';

class QrCameraPage extends StatefulWidget {
  const QrCameraPage({super.key});
  static const routeName = '/QrCameraPage';

  @override
  State<QrCameraPage> createState() => _QrCameraPageState();
}

class _QrCameraPageState extends State<QrCameraPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScan');
  Barcode? result;
  QRViewController? qrController;
  IconData icon = Icons.flash_off;
  @override
  void initState() {
    super.initState();
    qrController?.resumeCamera();
  }

  void resemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
            overlay: QrScannerOverlayShape(),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Positioned(
            top: 30,
            right: 25,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: IconButton(
                onPressed: () async {
                  await qrController?.toggleFlash();
                  final isFlashOn =
                      await qrController?.getFlashStatus() ?? false;
                  setState(() {
                    icon = isFlashOn ? Icons.flash_on : Icons.flash_off;
                  });
                },
                icon: Icon(icon),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 80,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.black.withOpacity(0.5),
              ),
              child: myWidget(),
            ),
          )
        ],
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen(
      (event) {
        setState(
          () {
            result = event;

            controller.pauseCamera();
            try {
              final qrCode = event.code.toString();
              logger.i(qrCode);
              // EasyLoading.showToast(qrCode);

              ///### Slipt String and use index
              List data = qrCode.split(',');

              context.read<QRScanProvider>().getResult(data[0]);

              logger.i(qrCode);
              log(qrCode);
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ResultQrPage(resultQr: qrCode),
              //   ),
              // );
            } on HttpException catch (error) {
              switch (error.message) {
                default:
              }
            }
          },
        );
        controller.pauseCamera();
        controller.resumeCamera();
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    qrController?.dispose();
  }
}

myWidget() => Builder(builder: (BuildContext context) {
      return Text(
        "Scan the customer's QR Code",
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Colors.white),
        // style: context.textTheme.titleMedium
        //     ?.copyWith(color: Colors.white),
      );
    });
