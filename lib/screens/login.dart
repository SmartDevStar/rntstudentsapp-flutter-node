import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';

import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/screens/splash.dart';

import 'package:rnt_app/responsive.dart';

class LoginPage extends StatefulWidget {
  static bool isAppThemeFetched = false;

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAppThemeFetched = false;

  List<MyTheme> _themes =
      defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyTheme> themes = [];

    if (!LoginPage.isAppThemeFetched) {
      final res = await fetchAppTheme();

      if (res['isError']) {
        final encodedThemeData = prefs.getString('appTheme');
        if (encodedThemeData == null) {
          themes =
              defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();
        } else {
          var decodedThemeData = json.decode(encodedThemeData);
          themes = (decodedThemeData as List)
              .map((theme) => MyTheme.fromJson(theme))
              .toList();
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Couldn't connect to server. Start offline mode..",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ));
      } else {
        String encodedAppTheme = json.encode(res['data']);
        // print("online-AppTheme : $encodedAppTheme");
        await prefs.setString('appTheme', encodedAppTheme);
        themes = res['data'];
      }
    } else {
      final encodedThemeData = prefs.getString('appTheme');
      if (encodedThemeData == null) {
        themes = defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();
      } else {
        var decodedThemeData = json.decode(encodedThemeData);
        themes = (decodedThemeData as List)
            .map((theme) => MyTheme.fromJson(theme))
            .toList();
      }
    }
    LoginPage.isAppThemeFetched = true;
    setState(() {
      isAppThemeFetched = true;
      _themes = themes;
    });
    if (prefs.containsKey('jwt')) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/home');
    }
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

        Navigator.pop(context);
        Navigator.pushNamed(context, '/home');

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
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: SafeArea(
        child: isAppThemeFetched
            ? Responsive(
                mobile: _buildMobileLoginPage(),
                desktop: Center(
                  child: _buildDesktopLoginPage(),
                ),
              )
            : const SplashPage(text: "Loading..."),
      ),
    );
  }

  Widget _buildLoginForm() {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 0.0, top: 5.0, right: 0, bottom: 5),
          child: Text(
            'نام کاربری',
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
                    borderSide: const BorderSide(color: Color(0xff222A35))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Color(0xff222A35))),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Colors.red))),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Padding(
          padding:
              const EdgeInsets.only(left: 0.0, top: 5.0, right: 0, bottom: 0),
          child: Text(
            'رمز عبور',
            style: TextStyle(
              color: convertHexToColor(_themes[0].labelFontColor!),
              fontSize: 18,
            ),
          ),
        ),
        // Container(
        //   alignment: Alignment.center,
        //   padding:
        //       const EdgeInsets.only(left: 30.0, top: 0.0, right: 30, bottom: 8),
        //   child: Text(
        //     ' ',
        //     style: TextStyle(
        //       color: convertHexToColor(_themes[0].labelFontColor!),
        //       fontSize: 10,
        //     ),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
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
                    borderSide: const BorderSide(color: Color(0xff222A35))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Color(0xff222A35))),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Colors.red))),
            obscureText: true,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: ElevatedButton(
            onPressed: () async {
              if (usernameController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                signIn(usernameController.text, passwordController.text);
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
              width: Responsive.isMobile(context) ? size.width * 0.35 : 250,
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
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: GestureDetector(
            onTap: () => {Navigator.pushNamed(context, '/pr')},
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
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
          child: GestureDetector(
            onTap: () => {Navigator.pushNamed(context, '/register')},
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
          margin:
              const EdgeInsets.only(left: 10, top: 30, right: 10, bottom: 5),
          child: const Text(
            "در صورتی که برای ورود به حساب کاربری خود با مشکل مواجه هستید با ما در ارتباط باشید",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/contact');
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
              width: Responsive.isMobile(context) ? size.width * 0.7 : 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  color: const Color(0xffffc000)),
              padding: const EdgeInsets.all(0),
              child: const Text(
                "ارتباط با ما",
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

  Widget _buildMobileLoginPage() {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
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
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildDesktopLoginPage() {
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
                child: _buildLoginForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
