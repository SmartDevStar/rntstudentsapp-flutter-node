import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rnt_app/models/customer_model.dart';

Future<Customer> getMyCusInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Customer myCusInfo = Customer();
  final encodedMyCusInfo = prefs.getString('myCusInfo');
  if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
    var decodedMyCusInfo = json.decode(encodedMyCusInfo);
    myCusInfo = Customer.fromJson(decodedMyCusInfo);
  }
  return myCusInfo;
}

Future<Uint8List> generateCertificate(
    PdfPageFormat pageFormat, String lan) async {
  final myCusInfo = await getMyCusInfo();
  final pdf = pw.Document();

  final ByteData fontData = await rootBundle.load('assets/fonts/0_Yekan.ttf');
  final pw.Font font = pw.Font.ttf(fontData.buffer.asByteData());

  final libreBaskerville = await PdfGoogleFonts.libreBaskervilleRegular();
  final libreBaskervilleItalic = await PdfGoogleFonts.libreBaskervilleItalic();
  final libreBaskervilleBold = await PdfGoogleFonts.libreBaskervilleBold();
  final netEnImage = await networkImage(
      'http://pnuglobal.dyndns.org:9001/uploads/files/idcardenglish.jpg');
  final netFaImage = await networkImage(
      'http://pnuglobal.dyndns.org:9001/uploads/files/idcardfarsi.jpg');
  final netProfileImage =
      await networkImage(myCusInfo.profilePhotoWebAddress ?? "");
  final netBackImage = lan == 'En' ? netFaImage : netEnImage;

  if (lan == "En") {
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(
            top: 155,
            left: 60,
            right: 120,
            bottom: 10,
          ),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: -135, right: 60),
                  child: pw.Image(netProfileImage,
                      fit: pw.BoxFit.fill, width: 190, height: 230),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    top: 130,
                  ),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: -30),
                          child: pw.Text(
                            myCusInfo.customerCode ?? 'Na',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: -100),
                          child: pw.Text(
                            myCusInfo.LastName ?? "",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 120),
                          child: pw.Text(
                            myCusInfo.FirstName ?? "",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 50),
                          child: pw.Text(
                            myCusInfo.fieldOfStudyDescription ?? "",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 20),
                          child: pw.Text(
                            DateFormat('d/M/y').format(DateTime.now()),
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                      ]),
                ),
              ]),
        ),
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
              height: 517),
          theme: pw.ThemeData.withFont(
            base: libreBaskerville,
            italic: libreBaskervilleItalic,
            bold: libreBaskervilleBold,
          ),
          buildBackground: (context) =>
              pw.Image(netBackImage, fit: pw.BoxFit.fill, height: 517),
        ),
      ),
    );
  } else {
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(
            top: 145,
            left: 135,
            right: 20,
            bottom: 10,
          ),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    top: 147,
                  ),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 70),
                          child: pw.Text(
                            myCusInfo.customerCode ?? 'Na',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 50),
                          child: pw.Text(
                            myCusInfo.LastName ?? "",
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: -90),
                          child: pw.Text(
                            myCusInfo.FirstName ?? "",
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 0),
                          child: pw.Text(
                            myCusInfo.fieldOfStudyDescription ?? "",
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: -40),
                          child: pw.Text(
                            DateFormat('d/M/y').format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                      ]),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: -135, right: 60),
                  child: pw.Image(netProfileImage,
                      fit: pw.BoxFit.fill, width: 190, height: 230),
                ),
              ]),
        ),
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
              height: 517),
          theme: pw.ThemeData.withFont(
            base: libreBaskerville,
            italic: libreBaskervilleItalic,
            bold: libreBaskervilleBold,
          ),
          buildBackground: (context) =>
              pw.Image(netBackImage, fit: pw.BoxFit.fill, height: 517),
        ),
      ),
    );
  }

  return pdf.save();
}
