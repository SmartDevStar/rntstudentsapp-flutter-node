import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart ' as pw;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/models/customer_model.dart';

class StudentCardPage extends StatefulWidget {
  const StudentCardPage({Key? key}) : super(key: key);

  @override
  State<StudentCardPage> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCardPage> {
  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));
  String stLanLabel = "English";
  String stIdExpireDate = "2000-12-29T00:00:00.000Z";
  Customer stMyCusInfo = Customer();
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> _setMyTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyTheme> themes = [];

    final encodedThemeData = prefs.getString('appTheme');
    if (encodedThemeData == null) {
      themes = defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();
    } else {
      var decodedThemeData = json.decode(encodedThemeData);
      themes = (decodedThemeData as List)
          .map((theme) => MyTheme.fromJson(theme))
          .toList();
    }

    setState(() {
      _themes = themes;
    });
  }

  Future<void> getMyCusInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Customer myCusInfo = Customer();
    final encodedMyCusInfo = prefs.getString('myCusInfo');
    if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
      var decodedMyCusInfo = json.decode(encodedMyCusInfo);
      myCusInfo = Customer.fromJson(decodedMyCusInfo);
    }
    setState(() {
      stMyCusInfo = myCusInfo;
    });
  }

  Future<void> getIdExpireDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedIdExpireDate = prefs.getString('idExpireDate');
    var decodedIdExpireDate = json.decode(encodedIdExpireDate!);
    print("idExpireDate: ${decodedIdExpireDate["lastStudyYearDateEnd"]}");
    if (decodedIdExpireDate != null && decodedIdExpireDate != "") {
      setState(() {
        stIdExpireDate = decodedIdExpireDate["lastStudyYearDateEnd"];
      });
    }
  }

  Future<void> printStudentCardAsPDF() async {
    String? downloadsDirectoryPath =
        (await DownloadsPath.downloadsDirectory())?.path;

    screenshotController
        .capture(delay: const Duration(milliseconds: 100))
        .then((capturedImage) async {
      final pdf = pw.Document();
      final image = pw.MemoryImage(
        capturedImage!,
      );
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(image.width! * PdfPageFormat.point,
              image.height! * PdfPageFormat.point),
          orientation: pw.PageOrientation.landscape,
          build: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(),
            child: pw.Image(image),
          ),
        ),
      );
      final pdfContent = await pdf.save();
      // Printing.sharePdf(bytes: pdfContent);

      File pdfFile = File('$downloadsDirectoryPath/StudentCard.pdf');
      pdfFile.writeAsBytesSync(pdfContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document printed at Downloads directory successfully'),
        ),
      );
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _setMyTheme();
    getMyCusInfo();
    getIdExpireDate();
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
    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: SafeArea(
        child: Row(
          children: [
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      printStudentCardAsPDF();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.0,
                      width: 65,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: const Color(0xffffc000)),
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        "ذخیره",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (stLanLabel == "English") {
                          stLanLabel = "فارسی";
                        } else {
                          stLanLabel = "English";
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.0,
                      width: 65,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: const Color(0xffffc000)),
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        stLanLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, bottom: 0.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: stLanLabel == "English"
                          ? const NetworkImage(
                              'http://pnuglobal.dyndns.org:9001/uploads/files/idcardfarsi.jpg')
                          : const NetworkImage(
                              'http://pnuglobal.dyndns.org:9001/uploads/files/idcardenglish.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child:
                      stLanLabel == "English" ? _buildFaCard() : _buildEnCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo(String txt1, String txt2, {String lan = 'Fa'}) {
    return lan == 'En'
        ? Row(
            children: <Widget>[
              Text(
                txt1,
                style: const TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: Colors.black),
              ),
              const SizedBox(width: 10.0, height: 0.0),
              Text(
                txt2,
                style: const TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Colors.black),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                txt1,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Colors.black),
              ),
              const SizedBox(width: 10.0, height: 0.0),
              Text(
                txt2,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontFamily: "Yekan",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black),
              ),
            ],
          );
  }

  Widget _buildEnCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 187.0),
              _buildStudentInfo(
                  "Student ID No:", "*${stMyCusInfo.customerCode}*",
                  lan: 'En'),
              const SizedBox(height: 2.0),
              _buildStudentInfo(
                  "Last Name:", stMyCusInfo.englishLastName ?? 'Na',
                  lan: 'En'),
              const SizedBox(height: 2.0),
              _buildStudentInfo("Name:", stMyCusInfo.englishFirstName ?? 'Na',
                  lan: 'En'),
              const SizedBox(height: 2.0),
              _buildStudentInfo("Studying:",
                  stMyCusInfo.fieldOfStudyDescriptionEnglish ?? 'Na',
                  lan: 'En'),
              const SizedBox(height: 2.0),
              _buildStudentInfo("Validity:",
                  DateFormat('d/M/y').format(DateTime.parse(stIdExpireDate)),
                  lan: 'En'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 90.0),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: stMyCusInfo.profilePhotoWebAddress != null &&
                        stMyCusInfo.profilePhotoWebAddress != ""
                    ? Image(
                        image:
                            NetworkImage(stMyCusInfo.profilePhotoWebAddress!),
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      )
                    : Container(),
              ),
              Padding(
                padding: const EdgeInsets.only(),
                child: Text(
                  "*${stMyCusInfo.customerCode}*",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'fre3of9x',
                    fontSize: 63,
                    letterSpacing: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            const SizedBox(height: 90.0),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 0),
              child: stMyCusInfo.profilePhotoWebAddress != null &&
                      stMyCusInfo.profilePhotoWebAddress != ""
                  ? Image(
                      image: NetworkImage(stMyCusInfo.profilePhotoWebAddress!),
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    )
                  : Container(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "*${stMyCusInfo.customerCode}*",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'fre3of9x',
                  fontSize: 63,
                  letterSpacing: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 173.0),
            _buildStudentInfo(
                "*${stMyCusInfo.customerCode}*", ":شماره دانشجویی"),
            const SizedBox(height: 2.0),
            _buildStudentInfo(stMyCusInfo.LastName ?? 'Na', ":نام خانوادگی"),
            const SizedBox(height: 2.0),
            _buildStudentInfo(stMyCusInfo.FirstName ?? 'Na', ":نام"),
            const SizedBox(height: 2.0),
            _buildStudentInfo(
                stMyCusInfo.fieldOfStudyDescription ?? 'Na', ":رشته"),
            const SizedBox(height: 2.0),
            _buildStudentInfo(
                DateFormat('d/M/y')
                    .format(DateTime.parse(convertUTC2Local(stIdExpireDate))),
                ":تاریخ انقضا"),
          ],
        ),
      ],
    );
  }
}
