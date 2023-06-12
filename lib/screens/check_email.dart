import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({super.key});

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
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

  @override
  void initState() {
    super.initState();
    _setMyTheme();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: convertHexToColor(_themes[0].bgColor!),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "رمز عبور به ایمیل شما ارسال خواهد شد",
              style: TextStyle(
                color: convertHexToColor(_themes[0].labelFontColor!),
                fontSize: 20,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
                  "بازیابی رمز عبور",
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
