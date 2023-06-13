import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/utils/consts.dart';
import 'package:rnt_app/utils/utils.dart';

import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/message_model.dart';

import 'package:rnt_app/screens/login.dart';
import 'package:rnt_app/screens/register.dart';
import 'package:rnt_app/screens/root.dart';
import 'package:rnt_app/screens/contact_us.dart';
import 'package:rnt_app/screens/password_recovery.dart';
import 'package:rnt_app/screens/check_email.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(
      callbackDispatcher,
    );
  }
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'fetchMessages') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Customer myCusInfo = Customer();

      final encodedMyCusInfo = prefs.getString('myCusInfo');
      if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
        var decodedMyCusInfo = json.decode(encodedMyCusInfo);
        myCusInfo = Customer.fromJson(decodedMyCusInfo);
      }

      final res = await fetchMessages();
      if (!res['isError']) {
        for (Message msg in res['data']) {
          if (msg.messageStatusID == 2 &&
              msg.recieptStatusID == 1 &&
              msg.recipientID == myCusInfo.registerID) {
            notificationApi.showNotification(
              id: msg.messageID,
              title: "<p style='text-align: right;'>${msg.subject}</p>",
              body: "<p style='text-align: right;'>${msg.messageBody}</p>",
            );
          }
        }
      }
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNT Students App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Yekan',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const RootPage(),
        '/contact': (context) => const ContactUsPage(),
        '/pr': (context) => const PasswordRecoveryPage(),
        '/checkemail': (context) => const CheckEmailPage(),
      },
    );
  }
}
