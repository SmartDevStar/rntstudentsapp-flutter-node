import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';

class StudentCardPage extends StatefulWidget {
  const StudentCardPage({Key? key}) : super(key: key);

  @override
  State<StudentCardPage> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCardPage> {
  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));
  String stLanLabel = "English";

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _setMyTheme();
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
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: stLanLabel == 'English'
                      ? const AssetImage('assets/images/studentcardBack_P.png')
                      : const AssetImage('assets/images/studentcardBack_E.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Container(
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
