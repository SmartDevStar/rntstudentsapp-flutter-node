import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:rnt_app/utils/utils.dart';

import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/message_model.dart';
import 'package:rnt_app/models/class_model.dart';

import 'package:rnt_app/screens/login.dart';
import 'package:rnt_app/screens/register.dart';
import 'package:rnt_app/screens/root.dart';
import 'package:rnt_app/screens/contact_us.dart';
import 'package:rnt_app/screens/password_recovery.dart';
import 'package:rnt_app/screens/check_email.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic notification',
            defaultColor: Colors.black,
            ledColor: Colors.white)
      ],
      debug: true
    );
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
    );
  }
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedMyCusInfo = prefs.getString('myCusInfo');
    Customer myCusInfo = Customer();
    if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
      var decodedMyCusInfo = json.decode(encodedMyCusInfo);
      myCusInfo = Customer.fromJson(decodedMyCusInfo);
    }
    if (taskName == 'fetchMessages') {
      final res = await fetchMessages();
      if (!res['isError']) {
        for (Message msg in res['data']) {
          if (msg.messageStatusID == 2 &&
              msg.recieptStatusID == 1 &&
              msg.recipientID == myCusInfo.registerID) {
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: msg.messageID,
                  channelKey: 'basic_channel',
                  title: "<p style='text-align: right;'>${msg.subject}</p>",
                  body: "<p style='text-align: right;'>${msg.messageBody}</p>",
              )
            );
            Map<String, dynamic> data = {
              "recipientID": msg.recipientID,
              "recieptStatusID": 3,
            };
            await updateMessageRecipientStatus(msg.messageID, data);
          }
        }
      }
    } else if(taskName == "fetchClasses") {
      DateTime now  = DateTime.now();
      final res = await fetchClasses();
      if (!res['isError']) {
        for (Class item in res['data']) {
          if (item.sessionDateTime != null && item.sessionDateTime !="") {
            DateTime scheduledDate = DateTime.parse(item.sessionDateTime!);
            if (now.isBefore(scheduledDate)) {
              int differenceInMinutes = scheduledDate.difference(now).inMinutes;
              if (differenceInMinutes <= 15 && (item.sessionStatusID == 1 || item.sessionStatusID == 2)) {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      id: item.classID ?? 101,
                      channelKey: 'basic_channel',
                      title: "تا دقایقی ئیگر",
                      body: "${item.classTitle} at ${convertDateTimeFormat(item.sessionDateTime!, "time")}",
                  )
                );
              }
            }
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