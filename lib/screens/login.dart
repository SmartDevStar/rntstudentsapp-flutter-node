import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';

import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/screens/root.dart';
import 'package:rnt_app/Screens/register.dart';
import 'package:rnt_app/Screens/contact_us.dart';
import 'package:rnt_app/Screens/password_recovery.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAuthed = false;

  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<bool> _checkAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('jwt')) {
      // Navigator.push(
      //   context, MaterialPageRoute(builder: (context) => const RootPage()));
      setState(() {
        isAuthed = true;
      });
      return true;
    } else {
      setState(() {
        isAuthed = false;
      });
      return false;
    }
  }

  Future<void> setMyTheme() async {
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

  Future<void> signIn(String username, String password) async {
    String url = "$serverDomain/api/auth/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> mapResponse = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt', mapResponse['token']);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const RootPage()));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Welcome to RNT!",
            style: TextStyle(color: Colors.lightGreen),
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Incorrect user info..",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Can't not reach out server..",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
    setMyTheme();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: isAuthed
            ? const RootPage()
            : ListView(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.memory(
                          base64Decode(_themes[5].fileData!.split(',').last),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.09),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, top: 5.0, right: 0, bottom: 5),
                      child: Text(
                        'نام کاربری (کد دانشجویی یا استادی)',
                        style: TextStyle(
                          color: convertHexToColor(_themes[0].labelFontColor!),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 35,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      // padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: usernameController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          color: convertHexToColor(_themes[1].datafontColor!),
                        ),
                        decoration: InputDecoration(
                            hintText: '',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: convertHexToColor(_themes[1].bgColor!),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Color(0xff222A35))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Color(0xff222A35))),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, top: 5.0, right: 0, bottom: 0),
                      child: Text(
                        'رمز عبور',
                        style: TextStyle(
                          color: convertHexToColor(_themes[0].labelFontColor!),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          left: 30.0, top: 0.0, right: 30, bottom: 8),
                      child: Text(
                        'رمز پیش فرض(اتباع ایرانی کد ملی بدون خط تیره یا فاصله) (اتباع غیر ایرانی ش شناسنامه)',
                        style: TextStyle(
                          color: convertHexToColor(_themes[0].labelFontColor!),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 35,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: passwordController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          color: convertHexToColor(_themes[1].datafontColor!),
                        ),
                        decoration: InputDecoration(
                            hintText: '',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: convertHexToColor(_themes[1].bgColor!),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Color(0xff222A35))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Color(0xff222A35))),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    const BorderSide(color: Colors.red))),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (usernameController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            signIn(usernameController.text,
                                passwordController.text);
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
                            "ورود",
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 0),
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PasswordRecoveryPage()))
                        },
                        child: const Text(
                          "بازیابی رمز عبور",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 5),
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()))
                        },
                        child: const Text(
                          "ثبت نام",
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.only(
                          left: 10, top: 30, right: 10, bottom: 5),
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()))
                        },
                        child: const Text(
                          "در صورتی که دانشجو و یا استاد دانشگاه پیام نور مرکز بین الملل هستید و امکان ورود به سیستم  برای شما نیست درخواست  بررسی ثبت نمایید",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ContactUsPage()));
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
                          width: size.width * 0.7,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.0),
                              color: const Color(0xffffc000)),
                          padding: const EdgeInsets.all(0),
                          child: const Text(
                            "ثبت درخواست بررسی عدم دسترسی",
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
              ]),
      ),
    );
  }
}
