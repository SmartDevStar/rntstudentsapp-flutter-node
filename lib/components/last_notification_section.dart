import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LastNotificationSection extends StatelessWidget {
  const LastNotificationSection(
      {
        super.key,
        this.onTap,
        required this.message,
        required this.receivedDate,
        this.isLastMsg = true,
        this.bgColor = const Color(0xffffc000),
        this.notificationColor = const Color(0xff000000),
        this.labelColor = const Color(0xff333F50),
      });

  final String message;
  final DateTime receivedDate;
  final Color? bgColor;
  final Color? labelColor;
  final bool isLastMsg;
  final Color? notificationColor;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.only(bottom: 5),
        color: bgColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if(isLastMsg)
                   Text(
                      "آخرین اعلان",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: labelColor,
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Transform.rotate(
                    angle: 25 * 3.14 / 180,
                    child: Icon(
                      Icons.notifications,
                      color: labelColor,
                    ),
                  ),
                )
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
              child: Text(
                DateFormat('dd-MM-yyyy HH:mm').format(receivedDate),
                style: TextStyle(
                  fontSize: 12,
                  color: notificationColor,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 0.0, bottom: 7.0),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: notificationColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}