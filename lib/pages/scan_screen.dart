import 'package:balanceit/utils/parsing/receipt_info.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../themes/colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final QRCodeChecker checker = FiscalQRCodeChecker();
  late QRViewController controller;
  ReceiptInfo? receiptInfo;
  String scanData = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: secondColor, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        this.scanData = scanData.code!;
        if (!checker.isFiscal(this.scanData)){
          showUnsupportedCodeDialog(context, controller);
          controller.pauseCamera();
        }
        else {
          receiptInfo = ReceiptInfo.fromString(this.scanData);
          this.controller.dispose();
          Navigator.pop(context, receiptInfo);
        }
      });

    });
  }
}
void showUnsupportedCodeDialog(BuildContext context, QRViewController controller) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Данный QR код не поддерживается"),
        content: const Text("Сосканируйте другой код или введите сумму вручную."),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              controller.resumeCamera();
            },
          ),
        ],
      );
    },
  );
}