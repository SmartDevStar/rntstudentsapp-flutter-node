import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/course_model.dart';
import 'package:rnt_app/models/class_model.dart';
import 'package:rnt_app/models/resource_model.dart';
import 'package:rnt_app/models/soa_model.dart';
import 'package:rnt_app/models/country_model.dart';
import 'package:rnt_app/models/message_model.dart';

import 'package:rnt_app/services/notification_services.dart';

import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/widgets/loading_widget.dart';
import 'package:rnt_app/widgets/null_data_widget.dart';
import 'package:rnt_app/widgets/bottombar_item.dart';

import 'package:rnt_app/components/last_notification_section.dart';
import 'package:rnt_app/components/sub_page_header_section.dart';
import 'package:rnt_app/components/sub_page_list_item.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final NotificationApi notificationApi;
  late FirebaseMessaging messaging;

  Timer? timer;
  bool _isLoading = false;
  bool isNewMessage = false;
  int _activePageIdx = 0;
  Map<String, bool> isDataFetched = {};
  Map<String, bool> isDataLoading = {
    'appTheme': false,
    'myCusInfo': false,
    'myClasses': false,
    'myCourses': false,
    'resources': false,
    'students': false,
    'soas': false,
    'countries': false,
    'messages': false,
  };
  final List<int> _pageTrack = [];
  final List<String> _alertedSessionDateTime = [];

  String _fcmToken = "";
  Course _activeCourse = Course();
  Class _activeClass = Class();
  Country _activeCountry = Country();
  int? _activeClassID;
  File? _avatarImage;
  Uint8List? _webImage;

  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));
  Customer stMyCustomerInfo = Customer();
  List<Class> stClasses = [];
  List<Course> stCourses = [];
  List<Resource> stResources = [];
  List<SOA> stSoas = [];
  List<Country> stCountries = [];
  Map<String, List<Customer>> stStudentsByCourseID = {};
  List<Message> stMessages = [];

  DateTime? _sessionDateTime = DateTime.now();
  DateTime? _sessionStartingTime = DateTime.now();
  DateTime? _dateOfBirth = DateTime.now();

  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  TextEditingController timeController = TextEditingController(
    text: DateFormat('HH:mm').format(DateTime.now()),
  );
  TextEditingController durationController = TextEditingController(text: "180");
  TextEditingController noteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController residentCountryIDController = TextEditingController();
  TextEditingController passportNoController = TextEditingController();
  TextEditingController nationalIDNoController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController nationalCardIDNoController = TextEditingController();
  TextEditingController messageToUsController = TextEditingController();
  TextEditingController messageToStudentsController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Future<void> getInitAppData() async {
    await getMyCustomerInfo();
    await getAppTheme();
    await getMessages();
    await getCountries();
    await getClasses();

    await setClassScheduleNotification();
  }

  Future<void> getAppTheme() async {
    setState(() {
      isDataLoading['appTheme'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyTheme> themes =
        defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();

    final res = await fetchAppTheme();

    if (res['isError']) {
      isDataFetched['appTheme'] = false;
      final encodedAppTheme = prefs.getString('appTheme');
      if (encodedAppTheme != null && encodedAppTheme != "") {
        print("offline-AppTheme : $encodedAppTheme");
        var decodedAppTheme = json.decode(encodedAppTheme);
        themes = (decodedAppTheme as List)
            .map((item) => MyTheme.fromJson(item))
            .toList();
      }
    } else {
      themes = res['data'];
      String encodedAppTheme = json.encode(res['data']);
      // print("online-AppTheme : $encodedAppTheme");
      await prefs.setString('appTheme', encodedAppTheme);
      isDataFetched['appTheme'] = true;
    }

    setState(() {
      isDataLoading['appTheme'] = false;
      _themes = themes;
    });
  }

  Future<void> getMyCustomerInfo() async {
    setState(() {
      isDataLoading['myCusInfo'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Customer myCusInfo = Customer();

    final res = await fetchMyCustomerInfo();

    if (res['isError']) {
      isDataFetched['myCusInfo'] = false;
      final encodedMyCusInfo = prefs.getString('myCusInfo');
      if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
        print("offline-myCusInfo : $encodedMyCusInfo");
        var decodedMyCusInfo = json.decode(encodedMyCusInfo);
        myCusInfo = Customer.fromJson(decodedMyCusInfo);
      }
    } else {
      myCusInfo = res['data'];
      String encodedMyCusInfo = json.encode(res['data']);
      // print("online-myCusInfo : $encodedMyCusInfo");
      await prefs.setString('myCusInfo', encodedMyCusInfo);
      isDataFetched['myCusInfo'] = true;
    }

    emailController.text = myCusInfo.email ?? "";
    contactNumberController.text = myCusInfo.contactNumber ?? "";
    residentCountryIDController.text = myCusInfo.residentCountryID.toString();
    passportNoController.text = myCusInfo.passportNo ?? "";
    nationalIDNoController.text = myCusInfo.nationalIDNo ?? "";
    try {
      dateOfBirthController.text = DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(myCusInfo.dateOfBirth!));
    } catch (e) {
      print(e);
      dateOfBirthController.text = "";
    }

    nationalCardIDNoController.text = myCusInfo.nationalCardIDNo ?? "";

    setState(() {
      isDataLoading['myCusInfo'] = false;
      stMyCustomerInfo = myCusInfo;
    });
  }

  Future<void> getClasses() async {
    setState(() {
      isDataLoading['myClasses'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Class> classes = [];

    final res = await fetchClasses();

    if (res['isError']) {
      isDataFetched['myClasses'] = false;
      final encodedClasses = prefs.getString('myClasses');
      if (encodedClasses != null && encodedClasses != "") {
        var decodedClasses = json.decode(encodedClasses);
        classes = (decodedClasses as List)
            .map((classe) => Class.fromJson(classe))
            .toList();
      }
    } else {
      classes = res['data'];
      String encodedClasses = json.encode(res['data']);
      await prefs.setString('myClasses', encodedClasses);
      isDataFetched['myClasses'] = true;
    }

    setState(() {
      isDataLoading['myClasses'] = false;
      stClasses = classes;
    });
  }

  Future<void> getCourses() async {
    setState(() {
      isDataLoading['myCourses'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Course> myCourses = [];

    final res = await fetchCourses();

    if (res['isError']) {
      isDataFetched['myCourses'] = false;
      final encodedMyCourses = prefs.getString('myCourses');
      if (encodedMyCourses != null && encodedMyCourses != "") {
        // print("offline-Courses : $encodedMyCourses");
        var decodedCourses = json.decode(encodedMyCourses);
        myCourses = (decodedCourses as List)
            .map((course) => Course.fromJson(course))
            .toList();
      }
    } else {
      myCourses = res['data'];
      String encodedMyCourses = json.encode(myCourses);
      // print("online-Courses : $encodedMyCourses");
      await prefs.setString('myCourses', encodedMyCourses);
      isDataFetched['myCourses'] = true;
    }

    setState(() {
      isDataLoading['myCourses'] = false;
      stCourses = myCourses;
    });
  }

  Future<void> getResources() async {
    setState(() {
      isDataLoading['resources'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Resource> resources = [];

    final res = await fetchResources();

    if (res['isError']) {
      isDataFetched['resources'] = false;
      final encodedResources = prefs.getString('resources');
      if (encodedResources != null && encodedResources != "") {
        // print("offline-Resources : $encodedResources");
        var decodedResources = json.decode(encodedResources);
        resources = (decodedResources as List)
            .map((resource) => Resource.fromJson(resource))
            .toList();
      }
    } else {
      resources = res['data'];
      String encodedResources = json.encode(resources);
      // print("online-Resources : $encodedResources");
      await prefs.setString('resources', encodedResources);
      isDataFetched['resources'] = true;
    }

    setState(() {
      isDataLoading['resources'] = false;
      stResources = resources;
    });
  }

  Future<void> getStudents(int courseID) async {
    setState(() {
      isDataLoading['students'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Customer> students = [];

    final res = await fetchStudents(stMyCustomerInfo.customerID ?? 0, courseID);

    if (res['isError']) {
      isDataFetched['students/$courseID'] = false;
      final encodedStudents = prefs.getString('students/$courseID');
      if (encodedStudents != null && encodedStudents != "") {
        // print("offline-Students/$courseID : $encodedStudents");
        var decodedStudents = json.decode(encodedStudents);
        students = (decodedStudents as List)
            .map((student) => Customer.fromJson(student))
            .toList();
      }
    } else {
      students = res['data'];
      String encodedStudents = json.encode(students);
      // print("online-Students/$courseID : $encodedStudents");
      await prefs.setString('students/$courseID', encodedStudents);
      isDataFetched['students/$courseID'] = true;
    }

    setState(() {
      isDataLoading['students'] = false;
      stStudentsByCourseID['students/$courseID'] = students;
    });
  }

  Future<void> getSoas() async {
    setState(() {
      isDataLoading['soas'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<SOA> soas = [];

    final res = await fetchSoas();

    if (res['isError']) {
      isDataFetched['soas'] = false;
      final encodedSoas = prefs.getString('soas');
      if (encodedSoas != null && encodedSoas != "") {
        print("offline-Soas : $encodedSoas");
        var decodedSoas = json.decode(encodedSoas);
        soas = (decodedSoas as List).map((soa) => SOA.fromJson(soa)).toList();
      }
    } else {
      soas = res['data'];
      String encodedSoas = json.encode(soas);
      // print("online-Soas : $encodedSoas");
      await prefs.setString('soas', encodedSoas);
      isDataFetched['soas'] = true;
    }

    setState(() {
      isDataLoading['soas'] = false;
      stSoas = soas;
    });
  }

  Future<void> getCountries() async {
    setState(() {
      isDataLoading['countries'] = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Country> countries = [];

    final res = await fetchCountries();

    if (res['isError']) {
      isDataFetched['countries'] = false;
      final encodedCountries = prefs.getString('countries');
      if (encodedCountries != null && encodedCountries != "") {
        print("offline-Countries : $encodedCountries");
        var decodedCountries = json.decode(encodedCountries);
        countries = (decodedCountries as List)
            .map((country) => Country.fromJson(country))
            .toList();
      }
    } else {
      countries = res['data'];
      String encodedCountries = json.encode(countries);
      // print("online-Countries : $encodedCountries");
      await prefs.setString('countries', encodedCountries);
      isDataFetched['countries'] = true;
    }

    setState(() {
      isDataLoading['countries'] = false;
      stCountries = countries;
    });
  }

  Future<void> getMessages() async {
    setState(() {
      isDataLoading['messages'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Message> messages = [];

    final res = await fetchMessages();

    if (res['isError']) {
      isDataFetched['messages'] = false;
      final encodedMessages = prefs.getString('messages');
      if (encodedMessages != null && encodedMessages != "") {
        print("offline-Messages : $encodedMessages");
        var decodedMessages = json.decode(encodedMessages);
        messages = (decodedMessages as List)
            .map((msg) => Message.fromJson(msg))
            .toList();
      }
    } else {
      messages = res['data'];
      String encodedMessages = json.encode(messages);
      // print("online-Messages : $encodedMessages");
      await prefs.setString('messages', encodedMessages);
      isDataFetched['messages'] = true;
    }

    setState(() {
      isDataLoading['messages'] = false;
      stMessages = messages;
    });

    for (Message msg in messages) {
      if (msg.messageStatusID == 2 &&
          msg.recieptStatusID == 1 &&
          msg.recipientID == stMyCustomerInfo.registerID) {
        Map<String, dynamic> data = {
          "recipientID": msg.recipientID,
          "recieptStatusID": 3,
        };
        updateMessageRecipientStatus(msg.messageID, data);
        setState(() {
          isNewMessage = true;
        });
      }
    }
  }

  List<Class> getClassesByCourseID(List<Class> allClasses, int courseID) {
    allClasses.sort((a, b) => a.sessionDateTime!.compareTo(b.sessionDateTime!));
    List<Class> todayClasses = allClasses
        .where((item) =>
            DateTime.parse(item.sessionDateTime!).day == DateTime.now().day &&
            DateTime.parse(item.sessionDateTime!).month ==
                DateTime.now().month &&
            DateTime.parse(item.sessionDateTime!).year == DateTime.now().year)
        .toList();

    if (courseID == -1) {
      return allClasses;
    }
    if (courseID == -3) {
      DateTime now = DateTime.now();
      List<Class> todayNextClasses = todayClasses
          .where((item) =>
              DateTime.parse(item.sessionDateTime!).compareTo(now) > 0)
          .toList();
      return todayNextClasses;
    }
    if (courseID == -2) {
      return todayClasses;
    } else {
      List<Class> filteredClasses =
          allClasses.where((item) => item.courseID == courseID).toList();
      return filteredClasses;
    }
  }

  List<Resource> getResourcesByCourseID(
      List<Resource> allResources, int courseID) {
    if (courseID == -1) {
      return allResources;
    } else {
      List<Resource> filteredResources =
          allResources.where((item) => item.courseID == courseID).toList();
      return filteredResources;
    }
  }

  List<Message> getChatMessages(List<Message> allMessages) {
    List<Message> chatMessages =
        allMessages.where((item) => item.isReminder == false).toList();
    chatMessages.sort((a, b) => a.createDate.compareTo(b.createDate));
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print(e);
    }
    return chatMessages;
  }

  List<Message> getNotifications(List<Message> allMessages) {
    List<Message> notifications = allMessages
        .where((item) =>
            item.isReminder == true &&
            item.recipientID == stMyCustomerInfo.registerID)
        .toList();
    return notifications;
  }

  Country getCountryByID(List<Country> allCounrtries, int nCountryID) {
    List<Country> countries = [];
    countries =
        allCounrtries.where((item) => item.countryID == nCountryID).toList();

    if (countries.isNotEmpty) {
      return countries[0];
    } else {
      return Country();
    }
  }

  Country getCountryByName(List<Country> allCounrtries, String strCountryName) {
    List<Country> countries = [];
    countries = allCounrtries
        .where((item) => item.countryName == strCountryName)
        .toList();
    if (countries.isNotEmpty) {
      return countries[0];
    } else {
      return Country();
    }
  }

  Message? getLastNotification(List<Message> allNotifications) {
    Message? lastNotification;
    for (Message item in allNotifications) {
      if (item.isReminder == true) {
        lastNotification = item;
        break;
      }
    }
    return lastNotification;
  }

  dynamic getTotalBalance(List<SOA> soas) {
    dynamic totalBalance = 0;
    for (SOA soa in soas) {
      totalBalance += soa.netTotalAmount;
    }
    return totalBalance;
  }

  Future<void> addClass(
    int? classID,
    String sessionDateTime,
    String sessionStartingTime,
    int sessionDuration,
    int sessionUpdatedBy,
  ) async {
    String url = "$serverDomain/api/courses/addclass";
    Map body = {
      "classID": _activeClassID ?? -1,
      "sessionDateTime": sessionDateTime,
      "sessionStartingTime": sessionStartingTime,
      "sessionDuration": sessionDuration,
      "sessionStatusID": 1,
      "sessionDeliveryStatusID": 6,
      "sessionUpdatedBy": sessionUpdatedBy,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");
    final res = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      setState(() {
        _activePageIdx = 6;
        _pageTrack.add(6);
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully added..",
          style: TextStyle(color: Colors.green),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something's wrong...",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  Future<void> sendMessage(Map<String, dynamic> data, int target) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");
    String url = "$serverDomain/api/customers/newmessage";
    bool isError = false;

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      var jsonAddMsgRes = json.decode(response.body);
      int messageID = jsonAddMsgRes["result"]["recordset"][0]["messageID"];
      url = "$serverDomain/api/customers/addrecipient/$messageID";

      if (target == 0) {
        final res = await http.put(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"recipientID": 5014, "recieptStatusID": 1}),
        );
        print("Call getMessage()");
        getMessages();
        if (res.statusCode != 200) {
          isError = true;
        }
      } else if (target == 1) {
        int courseID = _activeCourse.courseID!;
        for (Customer item
            in stStudentsByCourseID['students/$courseID'] ?? []) {
          if (item.RegisterID != 0) {
            final res = await http.put(
              Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(
                  {"recipientID": item.RegisterID, "recieptStatusID": 1}),
            );
            if (res.statusCode != 200) {
              isError = true;
            }
          }
        }
      }
    } else {
      isError = true;
    }

    if (!isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully sent..",
          style: TextStyle(
            color: Colors.green,
          ),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something went wrong..",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
    }
  }

  Future<void> sendFCMToken(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");
    String url = "$serverDomain/api/auth/sendtoken";
    bool isError = false;

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if(isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Could not send device token...",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  Future<void> removeFCMToken(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");
    String url = "$serverDomain/api/auth/removetoken";
    bool isError = false;

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        isError = true;
      }
    } catch (e) {
      print(e);
      isError = true;
    }

    if(isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Could not remove device token...",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  Future<void> _updateCustomerInfo(
      int customerID, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    String url = "$serverDomain/api/customers/update/$customerID";
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      getMyCustomerInfo();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully updated..",
          style: TextStyle(
            color: Colors.green,
          ),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something's wrong...",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  Future<void> updateNotificationRecipientStatus(int newStatus) async {
    List<Message> notifications = getNotifications(stMessages);
    for (Message msg in notifications) {
      if (msg.messageStatusID == 2 && msg.recieptStatusID != newStatus) {
        Map<String, dynamic> data = {
          "recipientID": msg.recipientID,
          "recieptStatusID": newStatus,
        };
        updateMessageRecipientStatus(msg.messageID, data);
      }
    }
  }

  Future<void> updateChatMsgRecipientStatus(int newStatus) async {
    List<Message> chatMessages = getChatMessages(stMessages);
    for (Message msg in chatMessages) {
      if (msg.messageStatusID == 2 &&
          msg.recieptStatusID != newStatus &&
          msg.recipientID == stMyCustomerInfo.registerID) {
        Map<String, dynamic> data = {
          "recipientID": msg.recipientID,
          "recieptStatusID": newStatus,
        };
        updateMessageRecipientStatus(msg.messageID, data);
      }
    }
  }

  Future<void> _logOut() async {
    notificationApi.cancelAllScheduledNotification();
    Map<String, dynamic> data = {
      "token": _fcmToken,
    };
    await removeFCMToken(data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('myCusInfo');
    await prefs.remove('myClasses');
    await prefs.remove('myCourses');
    await prefs.remove('resources');
    await prefs.remove('soas');
    await prefs.remove('messages');
    await prefs.remove('jwt');
    await prefs.remove('fcmToken');
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  void _refreshPage() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () async {
      await Future.wait([
        getAppTheme(),
        getMyCustomerInfo(),
        getCountries(),
        getClasses(),
        getCourses(),
        getResources(),
        getSoas(),
      ]);
      setState(() {
        _isLoading = false;
        _activePageIdx = 0;
      });
      await setClassScheduleNotification();
    });
  }

  Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile;
    } else {
      return null;
    }
  }

  Future<void> _handleAvatarUploadButtonPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");
    int customerID = stMyCustomerInfo.customerID!;
    String url = "$serverDomain/api/customers/upload/$customerID";

    final imageXFile = await pickImage(ImageSource.gallery);
    if (imageXFile == null) {
      return;
    }

    final uploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );
    uploadRequest.headers['Authorization'] = 'Bearer $token';

    if (!kIsWeb) {
      String imageFilePath = imageXFile.path;
      String fileExt = imageFilePath.split('.').last;
      String mimeType =
          mimeTypes[fileExt.toLowerCase()] ?? 'application/octet-stream';

      uploadRequest.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFilePath,
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      _webImage = await imageXFile.readAsBytes();
      Stream<List<int>> stream = Stream.fromIterable([_webImage!]);
      http.MultipartFile file = http.MultipartFile(
          'file', stream, _webImage!.length,
          filename: imageXFile.name,
          contentType: MediaType.parse(
              imageXFile.mimeType ?? "application/octet-stream"));
      uploadRequest.files.add(file);
    }

    var response = await uploadRequest.send();

    if (response.statusCode == 200) {
      getMyCustomerInfo();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully uploaded..",
          style: TextStyle(
            color: Colors.green,
          ),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something's wrong...",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }

  void checkNextRightClass(List<Class> allClasses) {
    DateTime now = DateTime.now();
    List<Class> notAlertedClasses = [];

    for (Class item in allClasses) {
      if (!_alertedSessionDateTime.contains(item.sessionDateTime!)) {
        notAlertedClasses.add(item);
      }
    }

    for (Class item in notAlertedClasses) {
      if (item.sessionDateTime != null && item.sessionDateTime != "") {
        DateTime scheduledDate = DateTime.parse(item.sessionDateTime!);
        if (now.isBefore(scheduledDate)) {
          int differenceInMinutes = scheduledDate.difference(now).inMinutes;
          if (differenceInMinutes <= 15 &&
              (item.sessionStatusID == 1 || item.sessionStatusID == 2)) {
            Map<String, String> data = {
              'title': "تا دقایقی دیگر",
              'body': item.classTitle ?? "Next class",
            };
            showNotification(data);
            _alertedSessionDateTime.add(item.sessionDateTime!);
          }
        }
      }
    }
  }

  void onSelectNotification() {
    setState(() {
      _activePageIdx = 2;
      _pageTrack.add(2);
    });
  }

  Future<void> setClassScheduleNotification() async {
    tz.TZDateTime timeZoneDateTime;
    DateTime sessionDateTime;
    DateTime now = DateTime.now();

    await notificationApi.cancelAllScheduledNotification();

    for (Class item in stClasses) {      
      if (item.sessionDateTime != null && item.sessionDateTime != "" && 
        (item.sessionStatusID == 1 || item.sessionStatusID == 2)) {
        
        sessionDateTime = DateTime.parse(item.sessionDateTime!);
        
        if (now.isBefore(sessionDateTime)) {
          int differenceInMinutes = sessionDateTime.difference(now).inMinutes;
          timeZoneDateTime = tz.TZDateTime.from(sessionDateTime, tz.local); 
          if (differenceInMinutes > 15) {
            timeZoneDateTime.subtract(const Duration(minutes: 15));
          }
          notificationApi.showScheduledNotification(
            id: item.hashCode,
            title: 'تا دقایقی دیگر',
            body: item.classTitle ?? "Next class",
            date: timeZoneDateTime,
            payload: "",
          ); 
        }
      }
    }
  }

  Future<void> initFirebaseMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    
    _fcmToken = fcmToken!;
    print("Current FCM Token: $_fcmToken");
    final prefsFCMToken = prefs.getString('fcmToken');
    if (prefsFCMToken == null || prefsFCMToken == '') {
      await prefs.setString('fcmToken', _fcmToken);
      Map<String, dynamic> data = {
        "lastUpdatedDate": DateTime.now().toUtc().toString(),
        "token": fcmToken,
      };
      sendFCMToken(data);
    }

    messaging.getInitialMessage().then((value) => {
        print(value?.data.toString())
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      print(message.notification?.body);
      notificationApi.showNotification(
        id: message.hashCode, 
        title: message.notification?.title ?? "", 
        body: message.notification?.body ?? "",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    print("FCM Initialization finished.");
  }

  @override
  void initState() {
    super.initState();
    _pageTrack.add(0);
    notificationApi = NotificationApi();
    notificationApi.initApi();
    initFirebaseMessage();
    getInitAppData();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      getMessages();
    });
  }

  @override
  void dispose() {
    notificationApi.cancelAllScheduledNotification();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> pages = {
      "Home": _buildHomePage(),
      "ContactUs": _buildContactUsPage(),
      "Notification": _buildNotificationPage(),
      "Refresh": _buildRefreshPage(),
      "MyCourses": _buildMyCoursesPage(),
      "CourseDetail": _buildCourseDetailPage(),
      "MyClassSchedule": _buildMyClassSchedulePage(),
      "AllClassSchedule": _buildAllClassSchedulePage(),
      "StudyResources": _buildStudyResourcesPage(),
      "RecordedClasses": _buildRecordedClassesPage(),
      "StudentsList": _buildStudentsListPage(),
      "TodayClasses": _buildTodayClassesPage(),
      "FinancialStatement": _buildFinancialStatementPage(),
      "AddNewClass": _buildAddNewClassPage(),
      "JoinClass": _buildJoinClassPage(),
      "SendMsgToAllStudents": _buildSendMsgToAllStudentsPage(),
      "Profile": _buildProfilePage(),
      "UploadDocuments": _buildUploadDocumentsPage(),
    };

    return WillPopScope(
        onWillPop: () async {
          if (_pageTrack.length > 1) {
            _pageTrack.removeLast();
            setState(() {
              _activePageIdx = _pageTrack.last;
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: convertHexToColor(_themes[0].bgColor!),
          bottomNavigationBar: _buildBottomBar(),
          body: Column(
            children: [
              _buildHeaderBar(),
              Expanded(
                child: _isLoading
                    ? _buildRefreshPage()
                    : pages[pageNames[_activePageIdx]]!,
              ),
            ],
          ),
        ));
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 5),
      color: convertHexToColor(_themes[2].bgColor!),
      child: isDataLoading['myCusInfo']!
          ? const LoadingView()
          : Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.only(top: 40.0, bottom: 0),
                          child: Text(
                            "اخرین بروز رسانی",
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  convertHexToColor(_themes[2].labelFontColor!),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.only(top: 2.0, bottom: 0),
                          child: Text(
                            // "25-4-2022 15:30",
                            DateFormat('dd-MM-yyyy hh:mm')
                                .format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  convertHexToColor(_themes[2].datafontColor!),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      stMyCustomerInfo.OrganizationDescription ?? "---",
                      style: TextStyle(
                        fontSize: 20,
                        color: convertHexToColor(_themes[2].datafontColor!),
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(top: 20, bottom: 0),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            color: const Color(0xFF323F4F),
                            onSelected: (value) => {
                              if (value == "LogOut")
                                _logOut()
                              else if (value == "Profile")
                                {
                                  setState(() {
                                    _activePageIdx = 16;
                                    _pageTrack.add(16);
                                    _activeCountry = getCountryByID(
                                        stCountries,
                                        stMyCustomerInfo.residentCountryID ??
                                            -1);
                                  })
                                } else if (value == "UploadDocuments") {
                                  setState(() {
                                    _activePageIdx = 17;
                                    _pageTrack.add(17);
                                  })
                                }
                            },
                            icon:
                                stMyCustomerInfo.profilePhotoWebAddress!.isEmpty
                                    ? IconTheme(
                                        data: IconThemeData(
                                          color: convertHexToColor(
                                              _themes[2].labelFontColor!),
                                          size: 50,
                                        ),
                                        child: const Icon(Icons.person))
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            stMyCustomerInfo
                                                .profilePhotoWebAddress!),
                                        radius: 21,
                                      ),
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: "name",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${stMyCustomerInfo.FirstName} ${stMyCustomerInfo.LastName}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].datafontColor!),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        ":نام",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: convertHexToColor(
                                              _themes[2].labelFontColor!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "code",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${stMyCustomerInfo.customerCode}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].datafontColor!),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        ":کد",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: convertHexToColor(
                                              _themes[2].labelFontColor!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "StudyLevel",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${stMyCustomerInfo.studyLevelDescription}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].datafontColor!),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        ":مقطع",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: convertHexToColor(
                                              _themes[2].labelFontColor!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "StudyField",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${stMyCustomerInfo.fieldOfStudyDescription}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].datafontColor!),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        ":رشته",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: convertHexToColor(
                                              _themes[2].labelFontColor!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: "Profile",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "اطلاعات شخصی",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].labelFontColor!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: "UploadDocuments",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "رسال مدارک",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].labelFontColor!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: "LogOut",
                                height: 27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "خروج",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: convertHexToColor(
                                            _themes[2].labelFontColor!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${stMyCustomerInfo.FirstName} ${stMyCustomerInfo.LastName}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                      ],
                    )),
              ],
            ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 76,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: convertHexToColor(_themes[4].bgColor!),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          tapIcons.length,
          (index) => BottomBarItem(tapIcons[index], tapLabels[index],
              isActive: _activePageIdx == index,
              isNotified: index == 2 && isNewMessage,
              color: convertHexToColor(_themes[4].labelFontColor!),
              activeColor: convertHexToColor(_themes[4].datafontColor!),
              onTap: () {
            if (index == 3) {
              _refreshPage();
            } else {
              if (index == 1) {
                updateChatMsgRecipientStatus(4);
                Future.delayed(const Duration(milliseconds: 300), () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                });
              }
              if (index == 2) {
                updateNotificationRecipientStatus(4);
                setState(() {
                  isNewMessage = false;
                });
              }
              setState(() {
                _activePageIdx = index;
                _pageTrack.add(index);
              });
            }
          }),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          title: "صفحه اصلی",
          icon: Icons.home,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    color: const Color(0xFF333F50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "درسهای من",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: SvgPicture.asset(
                            "assets/images/rescources.svg",
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(
                                convertHexToColor(_themes[0].labelFontColor!),
                                BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (isDataFetched.containsKey('myCourses')) {
                      if (!isDataFetched['myCourses']!) {
                        getCourses();
                      }
                    } else {
                      getCourses();
                    }
                    setState(() {
                      _activePageIdx = 4;
                      _pageTrack.add(4);
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    color: const Color(0xFF333F50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "برنامه کلاسهای من",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Icon(
                            Icons.calendar_month,
                            size: 30,
                            color:
                                convertHexToColor(_themes[0].labelFontColor!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _activePageIdx = 7;
                      _pageTrack.add(7);
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    color: const Color(0xFF333F50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "ورود به کلاس",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: SvgPicture.asset(
                            "assets/images/class.svg",
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(
                                convertHexToColor(_themes[0].labelFontColor!),
                                BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _activePageIdx = 11;
                      _pageTrack.add(11);
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    color: const Color(0xFF333F50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "صورت حساب مالی",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: SvgPicture.asset(
                            "assets/images/money.svg",
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(
                                convertHexToColor(_themes[0].labelFontColor!),
                                BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (isDataFetched.containsKey('soas')) {
                      if (!isDataFetched['soas']!) {
                        getSoas();
                      }
                    } else {
                      getSoas();
                    }
                    setState(() {
                      _activePageIdx = 12;
                      _pageTrack.add(12);
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    color: const Color(0xFF333F50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "کارت دانشجویی",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: IconTheme(
                            data: IconThemeData(
                              color: convertHexToColor(
                                  _themes[0].labelFontColor!),
                              size: 30,
                            ),
                            child: const Icon(Icons.contact_mail),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/studentcard');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactUsPage() {
    List<Message> chatMessages = getChatMessages(stMessages);
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          title: "گفتگو با ما",
          icon: Icons.contact_mail,
          svgIcon: "assets/images/chat.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: chatMessages.isNotEmpty
                ? Column(
                    children: [
                      ...List.generate(
                        chatMessages.length,
                        (index) => SubPageListItem(
                          subListType: SubPageListType.chatMessage,
                          messageDate: convertDateTimeFormat(
                              chatMessages[index].createDate, ""),
                          messageContent: chatMessages[index].messageBody,
                          messageSender: chatMessages[index].recipientID ==
                                  stMyCustomerInfo.registerID
                              ? "مرکز"
                              : "شما",
                          labelColor:
                              convertHexToColor(_themes[0].labelFontColor!),
                          dataColor:
                              convertHexToColor(_themes[0].datafontColor!),
                        ),
                      ),
                    ],
                  )
                : const NullDataView(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 2, bottom: 2),
                padding: EdgeInsets.zero,
                color: Colors.black,
                child: TextField(
                  controller: messageToUsController,
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                  // textDirection: TextDirection!.LTR,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    color: convertHexToColor(_themes[1].datafontColor!),
                  ),
                  decoration: InputDecoration(
                      hintText: 'پیغام',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: convertHexToColor(_themes[1].bgColor!),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(
                              color: convertHexToColor(_themes[1].bgColor!))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(
                              color: convertHexToColor(_themes[1].bgColor!))),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Colors.red))),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  if (messageToUsController.text.isNotEmpty) {
                    Map<String, dynamic> data = {
                      "createDate": DateTime.now().toUtc().toString(),
                      "subject": "New message from Client",
                      "messageBody": messageToUsController.text,
                      "parentMessageID": 0,
                      "expiryDate": "2000-01-20T00:00:00Z",
                      "isReminder": false,
                      "messageStatusID": 2,
                    };
                    print(data);
                    sendMessage(data, 0);
                    messageToUsController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 62.0,
                  width: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.0),
                      color: const Color(0xffffc000)),
                  padding: const EdgeInsets.all(0),
                  child: const Text(
                    "ارسال",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationPage() {
    List<Message> notifications = getNotifications(stMessages);
    return Column(
      children: [
        SubPageHeaderSection(
          title: "اعلان ها",
          icon: Icons.notifications,
          isRotate: true,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['messages']!
                ? const LoadingView()
                : notifications.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            notifications.length,
                            (index) => LastNotificationSection(
                              message:
                                  "${notifications[index].subject}: ${notifications[index].messageBody}",
                              receivedDate: DateTime.parse(
                                  notifications[index].createDate),
                              bgColor: const Color(0xFF333F50),
                              notificationColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              isLastMsg: false,
                            ),
                          ),
                        ],
                      )
                    : const NullDataView(),
          ),
        ), // Main Page
      ],
    );
  }

  Widget _buildRefreshPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "...دریافت اطلاعات",
              style: TextStyle(
                fontSize: 25,
                color: convertHexToColor(_themes[0].labelFontColor!),
              ),
            ),
            const LoadingView(),
          ]),
        ),
      ],
    );
  }

  Widget _buildMyCoursesPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          title: "درس های من",
          icon: Icons.book_rounded,
          svgIcon: "assets/images/rescources.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['myCourses']!
                ? const LoadingView()
                : stCourses.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            stCourses.length,
                            (index) => SubPageListItem(
                              subListType: SubPageListType.myCourses,
                              courseName: stCourses[index].courseDescription,
                              icon: Icons.book,
                              svgIcon: "assets/images/rescources.svg",
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              dataColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                              onTap: () {
                                setState(() {
                                  _activeCourse = stCourses[index];
                                  _activePageIdx = 5;
                                  _pageTrack.add(5);
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseDetailPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.courseDetail,
          title: "اطلاعات درس",
          courseName: _activeCourse.courseDescription,
          courseCode: "${_activeCourse.courseCode}",
          teacherName:
              "${_activeCourse.TeacherFirstName} ${_activeCourse.TeacherLastName}",
          courseUnits: _activeCourse.courseTotalUnit,
          icon: Icons.book_rounded,
          svgIcon: "assets/images/rescources.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SubPageListItem(
                  subListType: SubPageListType.normal,
                  title: "برنامه کلاسی",
                  icon: Icons.calendar_month,
                  labelColor: convertHexToColor(_themes[0].labelFontColor!),
                  dataColor: convertHexToColor(_themes[0].datafontColor!),
                  onTap: () {
                    setState(() {
                      _activePageIdx = 6;
                      _pageTrack.add(6);
                    });
                  },
                ),
                SubPageListItem(
                  subListType: SubPageListType.normal,
                  title: "منابع درسی",
                  icon: Icons.book,
                  svgIcon: "assets/images/rescources.svg",
                  labelColor: convertHexToColor(_themes[0].labelFontColor!),
                  dataColor: convertHexToColor(_themes[0].datafontColor!),
                  onTap: () {
                    if (isDataFetched.containsKey('resources')) {
                      if (!isDataFetched['resources']!) {
                        getResources();
                      }
                    } else {
                      getResources();
                    }
                    setState(() {
                      _activePageIdx = 8;
                      _pageTrack.add(8);
                    });
                  },
                ),
                SubPageListItem(
                  subListType: SubPageListType.normal,
                  title: "کلاسهای ضبط شده",
                  icon: Icons.camera,
                  svgIcon: "assets/images/record.svg",
                  labelColor: convertHexToColor(_themes[0].labelFontColor!),
                  dataColor: convertHexToColor(_themes[0].datafontColor!),
                  onTap: () {
                    setState(() {
                      _activePageIdx = 9;
                      _pageTrack.add(9);
                    });
                  },
                ),
                SubPageListItem(
                  subListType: SubPageListType.normal,
                  title: "اسامی دانشجویان",
                  icon: Icons.person,
                  labelColor: convertHexToColor(_themes[0].labelFontColor!),
                  dataColor: convertHexToColor(_themes[0].datafontColor!),
                  onTap: () {
                    int courseID = _activeCourse.courseID!;
                    if (isDataFetched.containsKey('students/$courseID')) {
                      if (!isDataFetched['students/$courseID']!) {
                        getStudents(courseID);
                      }
                    } else {
                      getStudents(courseID);
                    }
                    setState(() {
                      _activePageIdx = 10;
                      _pageTrack.add(10);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyClassSchedulePage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    List<Class> myClasses =
        getClassesByCourseID(stClasses, _activeCourse.courseID!);
    _activeClassID = myClasses.isNotEmpty ? myClasses[0].classID : -1;
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.myClassSchedule,
          title: _activeCourse.courseDescription,
          icon: Icons.calendar_month,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
          onAddClass: () {
            if (_activeClassID == -1 || stMyCustomerInfo.customerTypeID == 1) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Couldn't create a new class",
                  style: TextStyle(color: Colors.red),
                ),
              ));
            } else {
              setState(() {
                _activePageIdx = 13;
                _pageTrack.add(13);
              });
            }
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['myClasses']!
                ? const LoadingView()
                : myClasses.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            myClasses.length,
                            (index) => SubPageListItem(
                              subListType: SubPageListType.classSchedule,
                              title: myClasses[index].classTitle,
                              classStartDate: myClasses[index].sessionDateTime,
                              classStateId:
                                  myClasses[index].sessionDeliveryStatusID,
                              classStateDescription:
                                  myClasses[index].sessionStatusDescription,
                              icon: Icons.calendar_month,
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              dataColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                            ),
                          )
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildAllClassSchedulePage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    List<Class> classes = getClassesByCourseID(stClasses, -1);
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.normal,
          title: "تمام کلاس ها",
          icon: Icons.calendar_month,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['myClasses']!
                ? const LoadingView()
                : classes.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            classes.length,
                            (index) => SubPageListItem(
                              subListType: SubPageListType.classSchedule,
                              title: classes[index].classTitle,
                              classStartDate: classes[index].sessionDateTime,
                              classStateId:
                                  classes[index].sessionDeliveryStatusID,
                              classStateDescription:
                                  classes[index].sessionStatusDescription,
                              icon: Icons.calendar_month,
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              dataColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                            ),
                          )
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordedClassesPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    List<Class> courseClasses =
        getClassesByCourseID(stClasses, _activeCourse.courseID!);
    List<Class> recordedClasses = courseClasses
        .where((item) =>
            item.sessionRecodingWebLink != null &&
            item.sessionRecodingWebLink != "")
        .toList();
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.studyResources,
          title: "کلاس های ضبط شده",
          courseName: _activeCourse.courseDescription,
          icon: Icons.camera,
          svgIcon: "assets/images/record.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['myClasses']!
                ? const LoadingView()
                : recordedClasses.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            recordedClasses.length,
                            (index) => SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SubPageListItem(
                                subListType: SubPageListType.recordedClasses,
                                recordClassScreen:
                                    "assets/images/record_class.png",
                                recordDuration:
                                    recordedClasses[index].sessionDuration,
                                icon: Icons.camera,
                                svgIcon: "assets/images/record.svg",
                                labelColor: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                dataColor: convertHexToColor(
                                    _themes[0].datafontColor!),
                                onLinkRecordClass: () async {
                                  final uri = Uri.parse(recordedClasses[index]
                                      .sessionRecodingWebLink!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    throw 'Could not launch';
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildStudyResourcesPage() {
    List<Resource> resources =
        getResourcesByCourseID(stResources, _activeCourse.courseID!);
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.studyResources,
          title: "منابع درسی",
          courseName: _activeCourse.courseDescription,
          icon: Icons.book_rounded,
          svgIcon: "assets/images/rescources.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['resources']!
                ? const LoadingView()
                : resources.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            resources.length,
                            (index) => SubPageListItem(
                              subListType: SubPageListType.studyResources,
                              title: resources[index].resourceDescription,
                              publisher: resources[index].resourcePublisher,
                              icon: Icons.book,
                              svgIcon: "assets/images/rescources.svg",
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              dataColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                            ),
                          )
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsListPage() {
    int courseID = _activeCourse.courseID!;
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.studentsList,
          title: " دانشجویان این درس",
          icon: Icons.person,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
          onClickSendMsgToALlStudents: () {
            if (_activeClassID == -1 || stMyCustomerInfo.customerTypeID == 1) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "این گزینه فقط برای اساتید میباشد",
                  style: TextStyle(color: Colors.red),
                ),
              ));
            } else {
              setState(() {
                _activePageIdx = 15;
                _pageTrack.add(15);
              });
            }
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['students']!
                ? const LoadingView()
                : stStudentsByCourseID.containsKey('students/$courseID')
                    ? stStudentsByCourseID['students/$courseID']!.isNotEmpty
                        ? Column(
                            children: [
                              ...List.generate(
                                stStudentsByCourseID['students/$courseID']!
                                    .length,
                                (index) => SubPageListItem(
                                  subListType: SubPageListType.studentsList,
                                  title:
                                      "${stStudentsByCourseID['students/$courseID']![index].FirstName} ${stStudentsByCourseID['students/$courseID']![index].LastName}",
                                  studentEmail: stStudentsByCourseID[
                                          'students/$courseID']![index]
                                      .email,
                                  studentContactNo: stStudentsByCourseID[
                                          'students/$courseID']![index]
                                      .contactNumber,
                                  studentAvatar: stStudentsByCourseID[
                                          'students/$courseID']![index]
                                      .profilePhotoWebAddress,
                                  labelColor: convertHexToColor(
                                      _themes[0].labelFontColor!),
                                  dataColor: convertHexToColor(
                                      _themes[0].datafontColor!),
                                ),
                              )
                            ],
                          )
                        : const NullDataView()
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayClassesPage() {
    List<Class> classes = getClassesByCourseID(stClasses, -2);
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.normal,
          title: "کلاسهای امروز",
          icon: Icons.class_rounded,
          svgIcon: "assets/images/class.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isDataLoading['myClasses']!
                ? const LoadingView()
                : classes.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            classes.length,
                            (index) => SubPageListItem(
                              subListType: SubPageListType.todayClasses,
                              title: classes[index].classTitle,
                              classStartDate: classes[index].sessionDateTime,
                              classStateId:
                                  classes[index].sessionDeliveryStatusID,
                              classStateDescription:
                                  classes[index].sessionStatusDescription,
                              icon: Icons.class_rounded,
                              svgIcon: "assets/images/class.svg",
                              onJoinClass: () {
                                setState(() {
                                  _activeClass = classes[index];
                                  _activePageIdx = 14;
                                  _pageTrack.add(14);
                                });
                              },
                              labelColor:
                                  convertHexToColor(_themes[0].labelFontColor!),
                              dataColor:
                                  convertHexToColor(_themes[0].datafontColor!),
                            ),
                          )
                        ],
                      )
                    : const NullDataView(),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialStatementPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    dynamic totalBalance = getTotalBalance(stSoas);
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.normal,
          title: "صورت حساب مالی",
          icon: Icons.money,
          svgIcon: "assets/images/money.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: isDataLoading['soas']!
                      ? const LoadingView()
                      : stSoas.isNotEmpty
                          ? Column(
                              children: [
                                ...List.generate(
                                  stSoas.length,
                                  (index) => SubPageListItem(
                                    subListType:
                                        SubPageListType.financialStatement,
                                    transactionDate:
                                        stSoas[index].transactionDate,
                                    soaType: stSoas[index].type,
                                    netTotalAmount:
                                        stSoas[index].netTotalAmount,
                                    icon: Icons.note_alt_outlined,
                                    svgIcon: "assets/images/money.svg",
                                    labelColor: convertHexToColor(
                                        _themes[0].labelFontColor!),
                                    dataColor: convertHexToColor(
                                        _themes[0].datafontColor!),
                                  ),
                                )
                              ],
                            )
                          : const NullDataView(),
                ),
              ),
              Container(
                color: const Color(0xFF7F7F7F),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.zero,
                        child: Text(
                          "جمع",
                          style: TextStyle(
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontSize: 18,
                          ),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          stSoas.isNotEmpty
                              ? "${totalBalance.toStringAsFixed(1)} Euro"
                              : " Euro",
                          style: TextStyle(
                              color:
                                  convertHexToColor(_themes[0].datafontColor!),
                              fontSize: 18,
                              fontFamily: 'Roboto'),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewClassPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.addClass,
          title: "کلاس جدید",
          courseName: _activeCourse.courseDescription,
          icon: Icons.calendar_month,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF333F50),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.bottom,
                          readOnly: true,
                          style: TextStyle(
                            fontSize: 14,
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontFamily: 'Roboto',
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              prefixText: 'تاریخ:  ',
                              prefixStyle: TextStyle(
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                              ),
                              hintText: "تاریخ",
                              hintStyle:
                                  const TextStyle(color: Color(0xFF8497B0)),
                              suffixIcon: Icon(
                                Icons.calendar_month,
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                size: 40,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                          onTap: () async {
                            _sessionDateTime = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData(
                                    dialogBackgroundColor: const Color(
                                        0xFF323F4F), // Or any other color you'd like.
                                    fontFamily: 'Roboto',
                                    colorScheme: ColorScheme.fromSwatch(
                                            primarySwatch: Colors.yellow)
                                        .copyWith(
                                            secondary: Colors
                                                .yellow), // Set your font family here.
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (_sessionDateTime != null) {
                              setState(() {
                                dateController.text = DateFormat('dd-MM-yyyy')
                                    .format(_sessionDateTime!);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: const Color(0xFF333F50),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.bottom,
                          readOnly: true,
                          style: TextStyle(
                            fontSize: 14,
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontFamily: 'Roboto',
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              prefixText: 'ساعت:  ',
                              prefixStyle: TextStyle(
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                              ),
                              hintText: "تاریخ:",
                              hintStyle:
                                  const TextStyle(color: Color(0xFF8497B0)),
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                size: 40,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                          onTap: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                    data: ThemeData(
                                      // dialogBackgroundColor: const Color(0xFF323F4F), // Or any other color you'd like.
                                      fontFamily: 'Roboto',
                                      // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.yellow).copyWith(secondary: Colors.yellow), // Set your font family here.
                                    ),
                                    child: child!);
                              },
                            );
                            if (selectedTime != null) {
                              _sessionStartingTime = DateTime(
                                _sessionDateTime!.year,
                                _sessionDateTime!.month,
                                _sessionDateTime!.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              setState(() {
                                timeController.text =
                                    selectedTime.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: const Color(0xFF333F50),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: TextStyle(
                            fontSize: 14,
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontFamily: 'Roboto',
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              prefixText: 'مدت زمان (دقیقه): ',
                              prefixStyle: TextStyle(
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                              ),
                              hintText: "180min",
                              hintStyle: const TextStyle(
                                  color: Color(0xFF8497B0),
                                  fontFamily: 'Roboto'),
                              suffixIcon: Icon(
                                Icons.timer,
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                size: 40,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: const Color(0xFF333F50),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: TextStyle(
                            fontSize: 14,
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontFamily: 'Roboto',
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              hintText: "توضیحات",
                              hintStyle: const TextStyle(
                                  color: Color(0xFF8497B0),
                                  fontFamily: 'Roboto'),
                              suffixIcon: Icon(
                                Icons.note_alt_outlined,
                                color: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                size: 40,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF333F50))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      addClass(
                          _activeClassID,
                          convertLocal2UTC(_sessionDateTime.toString()),
                          _sessionStartingTime.toString(),
                          int.parse(durationController.text),
                          stMyCustomerInfo.customerID!);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.0,
                      width: 90,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: const Color(0xffffc000)),
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        "ذخیره",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinClassPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.normal,
          title: _activeClass.classTitle,
          icon: Icons.class_rounded,
          svgIcon: "assets/images/class.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  color: const Color(0xFF333F50),
                  padding: const EdgeInsets.all(100),
                  child: Center(
                    child: Text(
                      "جهت ورود به کلاس از تصب اپ مایکروسافت تیمز بر روی گوشی خود اطمینان حاصل فرمایید",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: convertHexToColor(_themes[0].datafontColor!),
                          fontSize: 20),
                    ),
                  ))),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: ElevatedButton(
            onPressed: () async {
              String msteamsUrl =
                  _activeClass.sessionWebLink!.replaceFirst("https", "msteams");
              final uri = Uri.parse(msteamsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "لطفا اپ مایکرویافت تمیز را نصب نمایید",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 40.0,
              width: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  color: const Color(0xffffc000)),
              padding: const EdgeInsets.all(0),
              child: const Text("ورود",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendMsgToAllStudentsPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.normal,
          title: "ارسال اعلامیه به دانشجویان من",
          icon: Icons.message,
          svgIcon: "assets/images/message.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 12),
                        child: Text(
                          "متن اعلامیه",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[0].labelFontColor!),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: const Color(0xFF333F50),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageToStudentsController,
                            textAlign: TextAlign.right,
                            textAlignVertical: TextAlignVertical.bottom,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                            decoration: InputDecoration(
                                hintText: "متن",
                                hintStyle: const TextStyle(
                                    color: Color(0xFF8497B0),
                                    fontFamily: 'Roboto'),
                                suffixIcon: Icon(
                                  Icons.note_alt_outlined,
                                  color: convertHexToColor(
                                      _themes[0].labelFontColor!),
                                  size: 40,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF333F50))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF333F50))),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        const BorderSide(color: Colors.red)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        const BorderSide(color: Colors.red))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              DateTime now = DateTime.now();
              DateTime tenDaysLater = now.add(const Duration(days: 10));

              if (messageToStudentsController.text.isNotEmpty) {
                Map<String, dynamic> data = {
                  "createDate": now.toUtc().toString(),
                  "subject":
                      "${stMyCustomerInfo.FirstName} ${stMyCustomerInfo.LastName}",
                  "messageBody": messageToStudentsController.text,
                  "parentMessageID": 0,
                  "expiryDate": tenDaysLater.toUtc().toString(),
                  "isReminder": true,
                  "messageStatusID": 2,
                };
                sendMessage(data, 1);
                setState(() {
                  _activePageIdx = 10;
                  _pageTrack.add(10);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 40.0,
              width: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  color: const Color(0xffffc000)),
              padding: const EdgeInsets.all(0),
              child: const Text("ارسال",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    if (_activeCountry == Country() && !stCountries.contains(Country())) {
      stCountries.add(Country());
    }
    if (_activeCountry != Country() && stCountries.contains(Country())) {
      stCountries.remove(Country());
    }
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          title: "اطلاعات شخصی",
          headerType: SubPageHeaderType.profile,
          avatarImage: _avatarImage,
          avatarAddress: stMyCustomerInfo.profilePhotoWebAddress,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
          onHeaderIconClicked: _handleAvatarUploadButtonPressed,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                    padding: const EdgeInsets.only(
                        left: 7.0, top: 7.0, right: 10, bottom: 7),
                    color: const Color(0xFF323F4F),
                    height: 57,
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          // textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              color:
                                  convertHexToColor(_themes[1].datafontColor!)),
                          decoration: InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(
                                  color: convertHexToColor(
                                      _themes[1].labelFontColor!)),
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF323F4F))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF323F4F))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Text(
                            ':ایمیل',
                            style: TextStyle(
                              color:
                                  convertHexToColor(_themes[1].labelFontColor!),
                              fontSize: 17,
                            ),
                          ))
                    ])),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: contactNumberController,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          // textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                              hintText: 'با کد کشور و بدون فاصله',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: convertHexToColor(_themes[1].bgColor!),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF323F4F))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF323F4F))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide:
                                      const BorderSide(color: Colors.red))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          ":تلفن تماس",
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          color: convertHexToColor(_themes[1].bgColor!),
                          child: DropdownButton<Country>(
                            dropdownColor:
                                convertHexToColor(_themes[1].bgColor!),
                            value: _activeCountry,
                            isExpanded: true,
                            items: stCountries.map((Country item) {
                              return DropdownMenuItem<Country>(
                                value: item,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        item.countryName,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ]),
                              );
                            }).toList(),
                            underline: Container(),
                            onChanged: (Country? selectedItem) {
                              setState(() {
                                _activeCountry = selectedItem!;
                              });
                            },
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          ":کشور محل سکونت",
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: passportNoController,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.bottom,
                      // textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: convertHexToColor(_themes[1].datafontColor!)),
                      decoration: InputDecoration(
                          hintText: '',
                          hintStyle: TextStyle(
                              color: convertHexToColor(
                                  _themes[1].labelFontColor!)),
                          filled: true,
                          fillColor: convertHexToColor(_themes[1].bgColor!),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red))),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          ':شماره پاسپورت',
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 17,
                          ),
                        ))
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: nationalIDNoController,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.bottom,
                      // textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: convertHexToColor(_themes[1].datafontColor!)),
                      decoration: InputDecoration(
                          hintText: 'فقط اعداد بدون فاصله',
                          hintStyle: TextStyle(
                              color: convertHexToColor(
                                  _themes[1].labelFontColor!)),
                          filled: true,
                          fillColor: convertHexToColor(_themes[1].bgColor!),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red))),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          ':شماره شناسنامه ',
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 17,
                          ),
                        ))
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: dateOfBirthController,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.bottom,
                      // textDirection: TextDirection.rtl,
                      readOnly: true,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: convertHexToColor(_themes[1].datafontColor!)),
                      decoration: InputDecoration(
                          hintText: 'میلادی',
                          hintStyle: TextStyle(
                              color: convertHexToColor(
                                  _themes[1].labelFontColor!)),
                          filled: true,
                          fillColor: convertHexToColor(_themes[1].bgColor!),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red))),
                      onTap: () async {
                        _dateOfBirth = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData(
                                dialogBackgroundColor: const Color(
                                    0xFF323F4F), // Or any other color you'd like.
                                fontFamily: 'Roboto',
                                colorScheme: ColorScheme.fromSwatch(
                                        primarySwatch: Colors.yellow)
                                    .copyWith(
                                        secondary: Colors
                                            .yellow), // Set your font family here.
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (_dateOfBirth != null) {
                          // setState(() {
                          dateOfBirthController.text =
                              DateFormat('dd-MM-yyyy').format(_dateOfBirth!);
                          // });
                        }
                      },
                    )),
                    Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          ':تاریخ تولد',
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 17,
                          ),
                        ))
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                  padding: const EdgeInsets.only(
                      left: 7.0, top: 7.0, right: 10, bottom: 7),
                  color: const Color(0xFF323F4F),
                  height: 57,
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: nationalCardIDNoController,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.bottom,
                      // textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: convertHexToColor(_themes[1].datafontColor!)),
                      decoration: InputDecoration(
                          hintText: 'فقط اعداد بدون فاصله',
                          hintStyle: TextStyle(
                              color: convertHexToColor(
                                  _themes[1].labelFontColor!)),
                          filled: true,
                          fillColor: convertHexToColor(_themes[1].bgColor!),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF323F4F))),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.red))),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          ':شماره کارت ملی',
                          style: TextStyle(
                            color:
                                convertHexToColor(_themes[1].labelFontColor!),
                            fontSize: 17,
                          ),
                        ))
                  ]),
                ),
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> customerInfo = {
                        "email": emailController.text,
                        "contactNumber": contactNumberController.text,
                        "residentCountryID": _activeCountry.countryID,
                        "passportNo": passportNoController.text,
                        "nationalIDNo": nationalIDNoController.text,
                        "dateOfBirth":
                            convertLocal2UTC(_dateOfBirth.toString()),
                        "nationalCardIDNo": nationalCardIDNoController.text,
                      };
                      _updateCustomerInfo(
                          stMyCustomerInfo.customerID!, customerInfo);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.0,
                      width: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: const Color(0xffffc000)),
                      padding: const EdgeInsets.all(0),
                      child: const Text("ذخیره",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDocumentsPage() {
    Message? lastNotification =
        getLastNotification(getNotifications(stMessages));
    return Column(
      children: [
        if (stMessages.isNotEmpty && lastNotification != null)
          LastNotificationSection(
            message:
                "${lastNotification.subject}: ${lastNotification.messageBody}",
            receivedDate: DateTime.parse(lastNotification.createDate),
            bgColor: convertHexToColor(_themes[3].bgColor!),
            notificationColor: convertHexToColor(_themes[3].datafontColor!),
            labelColor: convertHexToColor(_themes[3].labelFontColor!),
          ),
        SubPageHeaderSection(
          title: "ارسال مدارک",
          icon: Icons.message,
          svgIcon: "assets/images/message.svg",
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                      child: Text(
                        "توضیحات مدرک",
                        style: TextStyle(
                          color: convertHexToColor(_themes[0].labelFontColor!),
                          fontSize: 22,
                        )
                      ) 
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: const Color(0xff8296b0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 17.0,),
                            child: Text(
                              "فایلی انتخاب نشده",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          print("tapped!");
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFF333F50),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 17.0,),
                          child: Text(
                            "File description",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: const Color(0xff8296b0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 17.0,),
                            child: Text(
                              "فایلی انتخاب نشده",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFF333F50),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 17.0,),
                          child: Text(
                            "File description",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: const Color(0xff8296b0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 17.0,),
                            child: Text(
                              "فایلی انتخاب نشده",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFF333F50),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 17.0,),
                          child: Text(
                            "File description",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.0,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: const Color(0xffffc000)),
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        "ارسال",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}
