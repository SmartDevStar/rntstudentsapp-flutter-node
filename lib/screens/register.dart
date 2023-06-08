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
import 'package:rnt_app/screens/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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

  Future<void> _signUp(String name, String username, String emailaddress,
      String password) async {
    String url = "$serverDomain/api/auth/register";
    Map body = {
      "name": name,
      "username": username,
      "emailaddress": emailaddress,
      "password": password
    };
    var res = await http.Client().post(Uri.parse(url), body: body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully registerd..",
          style: TextStyle(color: Colors.green),
        ),
      ));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Already registered..",
          style: TextStyle(color: Colors.red),
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
                "assets/images/register.svg",
                colorFilter: ColorFilter.mode(
                                convertHexToColor(_themes[0].labelFontColor!),
                                BlendMode.srcIn),
                width: 55,
                height: 55,
              ))
        ],
      ),
    );
    Widget nameSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: TextField(
        controller: nameController,
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
    Widget userNameSection = Container(
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
            hintText: ':نام کاربری',
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
    Widget passwordSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: TextField(
        controller: passwordController,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.bottom,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: 18, color: convertHexToColor(_themes[1].datafontColor!)),
        obscureText: true,
        decoration: InputDecoration(
            hintText: ':رمز عبور',
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
    Widget confirmPasswordSection = Container(
      margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      padding: const EdgeInsets.only(left: 7.0, top: 7.0, right: 10, bottom: 7),
      color: const Color(0xFF323F4F),
      height: 57,
      child: TextField(
        controller: confirmPasswordController,
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.bottom,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: 18, color: convertHexToColor(_themes[1].datafontColor!)),
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'تأیید رمز عبور:',
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
    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: ListView(
        children: [
          headerSection,
          SubPageHeaderSection(
            title: "عضویت",
            svgIcon: "assets/images/register.svg",
            labelColor: convertHexToColor(_themes[0].labelFontColor!),
            dataColor: convertHexToColor(_themes[0].datafontColor!),
          ),
          nameSection,
          // codeSection,
          userNameSection,
          emailSection,
          // contactNoSection,
          passwordSection,
          confirmPasswordSection,
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    usernameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    _signUp(nameController.text, usernameController.text,
                        emailController.text, passwordController.text);
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "رمز عبور را به درستی وارد کنید",
                        style: TextStyle(color: Colors.red),
                      ),
                    ));
                  }
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
                width: size.width * 0.35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0.0),
                    color: const Color(0xffffc000)),
                padding: const EdgeInsets.all(0),
                child: const Text(
                  "ثبت نام",
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
