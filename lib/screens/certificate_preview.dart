import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:rnt_app/models/customer_model.dart';

import 'package:rnt_app/utils/certificate.dart';

class CertificatePreview extends StatefulWidget {
  const CertificatePreview({Key? key}) : super(key: key);

  @override
  State<CertificatePreview> createState() => _CertificatePreviewState();
}

class _CertificatePreviewState extends State<CertificatePreview> {
  Customer stMyCusInfo = Customer();
  String stLan = 'En';

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  // void _showSharedToast(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Document shared successfully'),
  //     ),
  //   );
  // }

  Future<void> changeLan(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    setState(() {
      if (stLan == 'En') {
        stLan = 'Fa';
      } else {
        stLan = 'En';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <PdfPreviewAction>[
      PdfPreviewAction(
        icon: Text(
          stLan,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 14,
          ),
        ),
        onPressed: changeLan,
      )
    ];
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PdfPreview(
        maxPageWidth: deviceWidth,
        build: (format) => generateCertificate(format, stLan),
        actions: actions,
        onPrinted: _showPrintedToast,
        canDebug: false,
        canChangeOrientation: true,
        allowSharing: false,
        canChangePageFormat: false,
      ),
    );
  }
}
