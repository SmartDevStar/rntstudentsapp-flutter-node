import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/course_model.dart';
import 'package:rnt_app/models/class_model.dart';
import 'package:rnt_app/models/resource_model.dart';
import 'package:rnt_app/models/soa_model.dart';

import 'package:rnt_app/utils/consts.dart';

Color convertHexToColor (String hexColor) {
  return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
}

String convertDateTimeFormat(String datetime, String format) {
  List<String> daysOfWeek = ['یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'];
  DateFormat dateFormat = DateFormat('d-M-y');
  DateFormat timeFormat = DateFormat('h:mm');

  DateTime dateTime = DateTime.parse(datetime);
  String dayName = daysOfWeek[dateTime.weekday - 1];

  switch(format) {
    case "full":
      return "${timeFormat.format(DateTime.parse(datetime))} $dayName ${dateFormat.format(DateTime.parse(datetime))} ساعت ";
    case "time":
      return "${timeFormat.format(DateTime.parse(datetime))} امروز ساعت ";
    default:
      return DateFormat('d-M-y h:mm').format(DateTime.parse(datetime));
  }
}

String convertToTime(int min) {
  int hours = (min / 60).floor();
  int remainingMinutes = min % 60;

  return '${hours}h:${remainingMinutes}m';
}

 Future<void> fetchAppDataFromServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    ///////////////////// fetch my customer info /////////////////////
    try {
      final myCusInfoRes = await http.get(
          Uri.parse('$serverDomain/api/customers/me'),
          headers: {'Authorization': 'Bearer $token'});

      if (myCusInfoRes.statusCode == 200) {
        var jsonMyCusInfo = json.decode(myCusInfoRes.body)[0];
        String encodedMyCusInfo =
            json.encode(Customer.fromMap(jsonMyCusInfo[0]));
        await prefs.setString('myCusInfo', encodedMyCusInfo);
      } else if (myCusInfoRes.statusCode == 404) {
        await prefs.setString('myCusInfo', "");
      }
    } catch (e) {
      throw Exception("Could not fetch my customer info!!!");
    }

    ///////////////////// fetch my courses /////////////////////
    try {
      final myCoursesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/mine'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonMyCourses = json.decode(myCoursesRes.body)[0];
      if (myCoursesRes.statusCode == 200) {
        List<Course> myCourses = (jsonMyCourses as List)
            .map((course) => Course.fromMap(course))
            .toList();
        String encodedMyCourses = json.encode(myCourses);
        await prefs.setString('myCourses', encodedMyCourses);
      } else if (myCoursesRes.statusCode == 404) {
        await prefs.setString('myCourses', "");
      }
    } catch (e) {
      throw Exception("Could not fetch my courses!!!");
    }

    ///////////////////// fetch my classes /////////////////////
    try {
      final classesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myclasses'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonClasses = json.decode(classesRes.body)[0];
      if (classesRes.statusCode == 200) {
        List<Class> classes = (jsonClasses as List)
            .map((myclass) => Class.fromMap(myclass))
            .toList();
        String encodedClasses = json.encode(classes);
        await prefs.setString('myClasses', encodedClasses);
      } else if (classesRes.statusCode == 404) {
        await prefs.setString('myClasses', "");
      }
    } catch (e) {
      throw Exception("Could not fetch my classes!!!");
    }

    ///////////////////// fetch my resources /////////////////////
    try {
      final resourcesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myresources'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonResources = json.decode(resourcesRes.body)[0];
      if (resourcesRes.statusCode == 200) {
        List<Resource> resources = (jsonResources as List)
            .map((resource) => Resource.fromMap(resource))
            .toList();
        String encodedResources = json.encode(resources);
        await prefs.setString('resources', encodedResources);
      } else if (resourcesRes.statusCode == 404) {
        await prefs.setString('resources', "");
      }
    } catch (e) {
      throw Exception("Could not fetch resources!!!");
    }

    ///////////////////// fetch my soa /////////////////////
    try {
      final soaRes = await http.get(
          Uri.parse('$serverDomain/api/customers/mysoa'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonSoas = json.decode(soaRes.body)[0];
      if (soaRes.statusCode == 200) {
        List<SOA> soas =
            (jsonSoas as List).map((myMap) => SOA.fromMap(myMap)).toList();
        String encodedSoas = json.encode(soas);
        await prefs.setString('soas', encodedSoas);
      } else if (soaRes.statusCode == 404) {
        await prefs.setString('soas', "");
      }
    } catch (e) {
      throw Exception("Could not fetch Soas!!!");
    }
  }

