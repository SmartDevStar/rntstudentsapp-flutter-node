import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/screens/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.text, this.duration = 1});

  final String text;
  final int duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isDataFetched = false;

  Future<void> fetchAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isError = false;
    List<MyTheme> themes =
        defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();

    try {
      final response = await http.get(
        Uri.parse('$serverDomain/api/setting/all'),
      );

      if (response.statusCode == 200) {
        var jsonThemeData = json.decode(response.body)[0];
        themes = (jsonThemeData as List)
            .map((myMap) => MyTheme.fromMap(myMap))
            .toList();
        String encodedAppTheme = json.encode(themes);
        print("online-AppTheme : $encodedAppTheme");
        await prefs.setString('appTheme', encodedAppTheme);
        setState(() {
          isDataFetched = true;
        });
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Couldn't connect to server. Start offline mode..",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
      setState(() {
        isDataFetched = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppTheme();
  }

  @override
  Widget build(BuildContext context) {
    return isDataFetched
      ? const LoginPage()
      : Scaffold(
          backgroundColor: const Color(0xff222A35),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 150,
                ),
                const SizedBox(
                  height: 50,
                ),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
