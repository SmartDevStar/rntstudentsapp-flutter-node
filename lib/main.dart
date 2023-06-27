import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'package:rnt_app/screens/login.dart';
import 'package:rnt_app/screens/register.dart';
import 'package:rnt_app/screens/root.dart';
import 'package:rnt_app/screens/contact_us.dart';
import 'package:rnt_app/screens/password_recovery.dart';
import 'package:rnt_app/screens/check_email.dart';
import 'package:rnt_app/screens/student_card.dart';
import 'package:rnt_app/screens/certificate_preview.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNT Students App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
        '/studentcard': (context) => const StudentCardPage(),
        '/certificate': (context) => const CertificatePreview(),
      },
    );
  }
}
