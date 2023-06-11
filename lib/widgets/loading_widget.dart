import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: CircularProgressIndicator(color: Colors.white,)),
      );
  }
}
