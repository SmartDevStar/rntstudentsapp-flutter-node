import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';

import 'package:rnt_app/screens/login.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String _userRole = '';
  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));

  void _handleRadioValueChange(String? value) {
    setState(() {
      _userRole = value!;
      print('User Role: $value');
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

  @override
  void initState() {
    super.initState();
    _setMyTheme();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Widget headerSection = Container(
      margin: const EdgeInsets.only(bottom: 50.0),
      padding:
          const EdgeInsets.only(left: 10.0, top: 1.0, bottom: 1.0, right: 10.0),
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
              "عضویت",
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
    );
    Widget roleSelectionSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding:
          const EdgeInsets.only(left: 30.0, top: 5.0, right: 30, bottom: 5),
      color: const Color(0xFF323F4F),
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
    );
    Widget nameSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
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
            hintText: ':نام',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: convertHexToColor(_themes[1].bgColor!),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red))),
      ),
    );
    Widget codeSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: TextField(
        // controller: usernameController,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.bottom,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: 18, color: convertHexToColor(_themes[1].datafontColor!)),
        decoration: InputDecoration(
            hintText: ':کد دانشجویی/کد استادی',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: convertHexToColor(_themes[1].bgColor!),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red))),
      ),
    );
    Widget emailSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: TextField(
        controller: emailController,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.bottom,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: 18, color: convertHexToColor(_themes[1].datafontColor!)),
        decoration: InputDecoration(
            hintText: ':ایمیل',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: convertHexToColor(_themes[1].bgColor!),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red))),
      ),
    );
    Widget contactNoSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              // controller: usernameController,
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.bottom,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 16,
                  color: convertHexToColor(_themes[1].datafontColor!)),
              decoration: InputDecoration(
                  hintText: 'Country Code',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Color(0xFF323F4F))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Color(0xFF323F4F))),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Colors.red))),
            ),
          ),
          Expanded(
            child: TextField(
              // controller: usernameController,
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.bottom,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 16,
                  color: convertHexToColor(_themes[1].datafontColor!)),
              decoration: InputDecoration(
                  hintText: 'Number',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Color(0xFF323F4F))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Color(0xFF323F4F))),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(color: Colors.red))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              ":تلفن تماس",
              style: TextStyle(
                color: convertHexToColor(_themes[1].labelFontColor!),
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
    Widget messageSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding:
          const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7.0),
      color: const Color(0xFF323F4F),
      height: 120,
      child: TextField(
        // controller: emailController,
        maxLines: null,
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
            //contentPadding: const EdgeInsets.symmetric(vertical: 40),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Color(0xFF323F4F))),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red))),
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xff222A35),
      body: ListView(
        children: [
          headerSection,
          roleSelectionSection,
          nameSection,
          codeSection,
          emailSection,
          contactNoSection,
          messageSection,
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                // signIn(usernameController.text, passwordController.text);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
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
                width: size.width * 0.35,
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
      ),
    );
  }
}
