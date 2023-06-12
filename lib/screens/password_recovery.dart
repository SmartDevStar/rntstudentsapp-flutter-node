import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/consts.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';

import 'package:rnt_app/components/sub_page_header_section.dart';

import 'package:rnt_app/responsive.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  TextEditingController uidController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));

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

  Future<void> _userCheck(Map<String, dynamic> data) async {
    final response = await http.get(
        Uri.parse('$serverDomain/api/setting/usercheck/${data['userID']}'));

    var jsonUser = json.decode(response.body)[0];
    if (response.statusCode == 200 && jsonUser.isNotEmpty) {
      if (jsonUser[0]["loginEmailAddress"] == emailController.text) {
        final response = await http.put(
          Uri.parse(
              '$serverDomain/api/setting/usercheck/sendpassrecoveryrequest'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "id": jsonUser[0]["UserName"],
            "email": jsonUser[0]["loginEmailAddress"]
          }),
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/checkemail');
        } else {
          if (response.statusCode == 400) {
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Server error..",
                style: TextStyle(color: Colors.red),
              ),
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Incorrect user info..",
            style: TextStyle(color: Colors.red),
          ),
        ));
      }
    } else {
      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "No user info..",
            style: TextStyle(color: Colors.red),
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Incorrect user info..",
            style: TextStyle(color: Colors.red),
          ),
        ));
      }
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
          mobile: _buildMobilePRPage(),
          desktop: Center(
            child: _buildDesktopPRPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildPRForm() {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SubPageHeaderSection(
          title: "بازیابی رمز عبور",
          svgIcon: "assets/images/password.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: const Color(0xFF323F4F),
          height: 57,
          child: TextField(
            controller: uidController,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontSize: 18,
                color: convertHexToColor(_themes[1].datafontColor!)),
            decoration: InputDecoration(
              hintText: ':کد دانشجویی/کد استادی',
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
              hintText: ':ایمیل',
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
              if (uidController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                _userCheck({
                  "userID": uidController.text,
                  "email": emailController.text
                });
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
                "نام کاربری",
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

  Widget _buildMobilePRPage() {
    return SingleChildScrollView(
      child: Column(
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
                    "بازیابی رمز عبور",
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
                      "assets/images/password.svg",
                      colorFilter: ColorFilter.mode(
                          convertHexToColor(_themes[2].labelFontColor!),
                          BlendMode.srcIn),
                      width: 55,
                      height: 55,
                    ))
              ],
            ),
          ),
          _buildPRForm(),
        ],
      ),
    );
  }

  Widget _buildDesktopPRPage() {
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
                child: _buildPRForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
