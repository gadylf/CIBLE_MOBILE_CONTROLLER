import 'package:cible_controlleur/helpers/colorsHelpers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Theme.of(context).platform == TargetPlatform.android) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            buildQrView(context),
            Positioned(bottom: 50, child: buildResult()),
            Positioned(bottom: 150, child: buildControlButton()),
          ],
        ),
      ),
    );
  }

  Widget buildControlButton() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Icon(
                          snapshot.data! ? Icons.flash_on : Icons.flash_off);
                    } else {
                      return Container();
                    }
                  }),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
          ],
        ),
      );

  Widget buildResult() {
    if (barcode != null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          width: double.maxFinite / 2,
          height: double.maxFinite / 2,
          child: Column(
            children: [
              Text(
                barcode!.code == "https://boxicons.com/usage"
                    ? 'Valide'
                    : 'Invalid',
              )
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderLength: 10,
          borderRadius: 10,
          borderWidth: 10,
          borderColor: AppColor.primary,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) => setState(() {
          this.barcode = barcode;
        }));
  }
}
