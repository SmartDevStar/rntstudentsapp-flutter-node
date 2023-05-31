import 'package:flutter/material.dart';

class ErrorDataView extends StatelessWidget {
  const ErrorDataView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
          "Oops!, I can't reach out server..",
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
          ),
        )
    );
  }
}
