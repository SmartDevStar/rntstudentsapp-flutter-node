import 'package:flutter/material.dart';

class NullDataView extends StatelessWidget {
  final String text = "There is no data to display..";
  const NullDataView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ), 
      ), 
    );
  }
}
