import 'dart:core';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/course_model.dart';
import 'package:rnt_app/models/class_model.dart';
import 'package:rnt_app/models/resource_model.dart';
import 'package:rnt_app/models/soa_model.dart';
import 'package:rnt_app/models/country_model.dart';
import 'package:rnt_app/models/message_model.dart';


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

String convertUTC2Local(String strUtcTime) {
  DateTime utcDateTime;
  DateTime localDateTime;
  String localTimeString;

  try {
    utcDateTime = DateTime.parse(strUtcTime);
    localDateTime = utcDateTime.toLocal();
    localTimeString = localDateTime.toString();
  } catch (e) {
    localTimeString = ""; 
  }
  
  return localTimeString;
}

String convertLocal2UTC(String strLocalTime) {
  DateTime localTime = DateTime.parse(strLocalTime);
  Duration offset = DateTime.now().timeZoneOffset;
  DateTime utcTime = localTime.subtract(offset);
  String utcTimeString = utcTime.toString();
  return utcTimeString;
}


////////////////////////////// Fetch Data From Backend /////////////////////////////////
/*
  Response : Map<String, dynamic>
  {
    'data': fetchedData,
    'isError': true/false,
  }
*/

  Future<Map<String, dynamic>> fetchAppTheme() async {
    List<MyTheme> themes = [];
    bool isError = false;

    try {
      final response = await http.get(
        Uri.parse('$serverDomain/api/setting/all'),
      );

      if (response.statusCode == 200) {
        var jsonThemeData = json.decode(response.body)[0];
        themes = (jsonThemeData as List)
            .map((myMap) => MyTheme.fromMap(myMap))
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': themes,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchMyCustomerInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    Customer myCusInfo = Customer();
    bool isError = false;

    try {
      final myCusInfoRes = await http.get(
          Uri.parse('$serverDomain/api/customers/me'),
          headers: {'Authorization': 'Bearer $token'});

      if (myCusInfoRes.statusCode == 200) {
        var jsonMyCusInfo = json.decode(myCusInfoRes.body)[0];
        myCusInfo = Customer.fromMap(jsonMyCusInfo[0]);
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': myCusInfo,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    List<Class> classes = [];
    bool isError = false;

    try {
      final classesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myclasses'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonClasses = json.decode(classesRes.body)[0];
      if (classesRes.statusCode == 200) {
        classes = (jsonClasses as List)
            .map((myclass) => Class.fromMap(myclass))
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': classes,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    List<Course> myCourses = [];
    bool isError = false;

    try {
      final myCoursesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/mine'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonMyCourses = json.decode(myCoursesRes.body)[0];
      if (myCoursesRes.statusCode == 200) {
        myCourses = (jsonMyCourses as List)
            .map((course) => Course.fromMap(course))
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': myCourses,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchResources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    List<Resource> resources = [];
    bool isError = false;

    try {
      final resourcesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myresources'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonResources = json.decode(resourcesRes.body)[0];
      if (resourcesRes.statusCode == 200) {
        resources = (jsonResources as List)
            .map((resource) => Resource.fromMap(resource))
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': resources,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchStudents(int customerID, int courseID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    List<Customer> students = [];
    bool isError = false;

    try {
      final response = await http.get(
          Uri.parse('$serverDomain/api/courses/allstudents/$courseID'),
          headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        var jsonStudents = json.decode(response.body)[0];
        students = (jsonStudents as List)
            .map((myMap) => Customer.fromMap(myMap))
            .toList();
        students = students
            .where((item) => item.customerID != customerID)
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': students,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchSoas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    List<SOA> soas = [];
    bool isError = false;

    try {
      final soaRes = await http.get(
          Uri.parse('$serverDomain/api/customers/mysoa'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonSoas = json.decode(soaRes.body)[0];
      if (soaRes.statusCode == 200) {
        soas = (jsonSoas as List).map((myMap) => SOA.fromMap(myMap)).toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': soas,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchCountries() async {
    List<Country> countries = [];
    bool isError = false;

    try {
      final countryRes =
          await http.get(Uri.parse('$serverDomain/api/setting/countries'));

      var jsonCountries = json.decode(countryRes.body)[0];
      if (countryRes.statusCode == 200) {
        countries = (jsonCountries as List)
            .map((myMap) => Country.fromMap(myMap))
            .toList();
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': countries,
      'isError': isError,
    };
  }

  Future<Map<String, dynamic>> fetchMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    List<Message> messages = [];
    bool isError = false;

    try {
      final messageRes = await http.get(
          Uri.parse('$serverDomain/api/customers/getmessages'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonMessages = json.decode(messageRes.body)[0];
      if (messageRes.statusCode == 200) {
        messages = (jsonMessages as List)
            .map((myMap) => Message.fromMap(myMap))
            .toList();
        messages.sort((a, b) => b.createDate.compareTo(a.createDate));
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    return {
      'data': messages,
      'isError': isError,
    };
  }

  Future<void> updateMessageRecipientStatus(
      int messageID, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    String url = "$serverDomain/api/customers/updaterecipientstatus/$messageID";
    await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }