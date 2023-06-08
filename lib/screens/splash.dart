import 'package:flutter/material.dart';

import 'package:rnt_app/screens/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.text, this.duration = 1});

  final String text;
  final int duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
    return Scaffold(
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
