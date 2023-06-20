import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/components/sub_page_header_section.dart';

import 'package:rnt_app/responsive.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  String _userRole = 'teacher';
  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  void _handleRadioValueChange(String? value) {
    setState(() {
      _userRole = value!;
    });
  }

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

  Future<void> sendContactMessage(Map<String, dynamic> data) async {
    String url = "$serverDomain/api/customers/noaccessmessage";

    final res = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully sent..",
          style: TextStyle(
            color: Colors.green,
          ),
        ),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something went wrong..",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _setMyTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: SafeArea(
        child: Responsive(
          mobile: _buildMobileContactUsPage(),
          desktop: Center(
            child: _buildDesktopContactUsPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildContactUsForm() {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          color: convertHexToColor(_themes[1].bgColor!),
          child: Row(
            children: [
              Radio(
                value: 'teacher',
                groupValue: _userRole,
                fillColor: MaterialStateProperty.all<Color>(Colors.white),
                onChanged: _handleRadioValueChange,
              ),
              Expanded(
                child: Text(
                  'استاد',
                  style: TextStyle(
                    color: convertHexToColor(_themes[1].labelFontColor!),
                    fontSize: 18,
                  ),
                ),
              ),
              Radio(
                value: 'student',
                groupValue: _userRole,
                fillColor: MaterialStateProperty.all<Color>(Colors.white),
                onChanged: _handleRadioValueChange,
              ),
              Text(
                'دانشجو',
                style: TextStyle(
                  color: convertHexToColor(_themes[1].labelFontColor!),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          child: TextField(
            controller: usernameController,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              color: convertHexToColor(_themes[1].datafontColor!),
            ),
            decoration: InputDecoration(
              hintText: 'نام',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: convertHexToColor(_themes[1].bgColor!),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          child: TextField(
            controller: codeController,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              color: convertHexToColor(_themes[1].datafontColor!),
            ),
            decoration: InputDecoration(
              hintText: 'کد دانشجویی/کد استادی',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: convertHexToColor(_themes[1].bgColor!),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          child: TextField(
            controller: emailController,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontSize: 18,
                color: convertHexToColor(_themes[1].datafontColor!)),
            decoration: InputDecoration(
              hintText: 'ایمیل',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: convertHexToColor(_themes[1].bgColor!),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          child: TextField(
            controller: contactController,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16,
              color: convertHexToColor(_themes[1].datafontColor!),
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              hintText: 'تلفن تماس',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: convertHexToColor(_themes[1].bgColor!),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          child: TextField(
            controller: messageController,
            maxLines: 3,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              color: convertHexToColor(_themes[1].datafontColor!),
            ),
            decoration: InputDecoration(
              hintText: 'توضیحات',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: convertHexToColor(_themes[1].bgColor!),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                      color: convertHexToColor(_themes[1].bgColor!))),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ElevatedButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty &&
                  codeController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  contactController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                Map<String, dynamic> data = {
                  "name": usernameController.text,
                  "code": codeController.text,
                  "email": emailController.text,
                  "contact": contactController.text,
                  "description": messageController.text,
                  "type": _userRole == 'student' ? 1 : 2,
                  "source": 1,
                };
                sendContactMessage(data);
              }
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
              width:
                  Responsive.isMobile(context) ? size.width * 0.35 : size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  color: const Color(0xffffc000)),
              padding: const EdgeInsets.all(0),
              child: const Text(
                "ارسال",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContactUsPage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50.0),
          padding: const EdgeInsets.only(
              left: 10.0, top: 1.0, bottom: 1.0, right: 10.0),
          color: convertHexToColor(_themes[2].bgColor!),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                    height: 57,
                    width: 57,
                    child: Image.memory(
                      base64Decode(_themes[5].fileData!.split(',').last),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "ارتباط با ما",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: convertHexToColor(_themes[2].labelFontColor!),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.zero,
                  child: SvgPicture.asset(
                    "assets/images/message.svg",
                    colorFilter: ColorFilter.mode(
                        convertHexToColor(_themes[2].labelFontColor!),
                        BlendMode.srcIn),
                    width: 55,
                    height: 55,
                  ))
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _buildContactUsForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContactUsPage() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 120,
            width: 120,
            child: Image.memory(
              base64Decode(_themes[5].fileData!.split(',').last),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 450,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SubPageHeaderSection(
                      title: "ارتباط با ما",
                      svgIcon: "assets/images/message.svg",
                      labelColor: convertHexToColor(_themes[0].labelFontColor!),
                      dataColor: convertHexToColor(_themes[0].datafontColor!),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _buildContactUsForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
