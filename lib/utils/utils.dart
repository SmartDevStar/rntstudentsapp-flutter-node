import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color convertHexToColor (String hexColor) {
  return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
}

String convertDateTimeFormat(String datetime, String? format) {
  List<String> daysOfWeek = ['یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'];

  DateTime dateTime = DateTime.parse(datetime);
  String dayName = daysOfWeek[dateTime.weekday - 1];
  String strTime = DateFormat.Hm().format(dateTime);
  String strDate = DateFormat('d-M-y').format(dateTime);

  switch(format) {
    case "full":
      return "$strTime $dayName $strDate ساعت ";
    case "time":
      return "$strTime امروز ساعت ";
    default:
      return "$strDate $strTime";
  }
}

String convertToTime(int min) {
  int hours = (min / 60).floor();
  int remainingMinutes = min % 60;

  return '${hours}h:${remainingMinutes}m';
}

