import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rnt_app/models/theme_model.dart';
import 'package:rnt_app/models/customer_model.dart';
import 'package:rnt_app/models/course_model.dart';
import 'package:rnt_app/models/class_model.dart';
import 'package:rnt_app/models/resource_model.dart';
import 'package:rnt_app/models/soa_model.dart';
import 'package:rnt_app/models/message_model.dart';

import 'package:rnt_app/utils/utils.dart';
import 'package:rnt_app/utils/data.dart';
import 'package:rnt_app/utils/consts.dart';

import 'package:rnt_app/widgets/loading_widget.dart';
import 'package:rnt_app/widgets/null_data_widget.dart';
import 'package:rnt_app/widgets/bottombar_item.dart';

import 'package:rnt_app/components/last_notification_section.dart';
import 'package:rnt_app/components/sub_page_header_section.dart';
import 'package:rnt_app/components/sub_page_list_item.dart';

import 'package:rnt_app/screens/login.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoading = false;
  int _activePageIdx = 0;
  Map<String, bool> isDataFetched = {};
  Map<String, bool> isDataLoading = {
    'myCusInfo': false,
    'myClasses': false,
    'myCourses': false,
    'resources': false,
    'students': false,
    'soas': false,
  };
  final List<int> _pageTrack = [];

  Course _activeCourse = Course();
  Class _activeClass = Class();
  int? _activeClassID;

  List<MyTheme> _themes = List.generate(
      defaultThemes.length, (index) => MyTheme.fromMap(defaultThemes[index]));
  Customer stMyCustomerInfo = Customer();
  List<Class> stClasses = [];
  List<Course> stCourses = [];
  List<Resource> stResources = [];
  List<SOA> stSoas = [];
  Map<String, List<Customer>> stStudentsByCourseID = {};
  final List<Message> _messageList = [];

  DateTime? _sessionDateTime = DateTime.now();
  DateTime? _sessionStartingTime = DateTime.now();
  DateTime? _dateOfBirth = DateTime.now();

  String _selectedCountryCode = "+971";
  String _selectedCountry = "United Arab Emirates";

  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  TextEditingController timeController = TextEditingController(
    text: DateFormat('HH:mm').format(DateTime.now()),
  );
  TextEditingController durationController = TextEditingController(text: "180");
  TextEditingController noteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController residentCountryIDController = TextEditingController();
  TextEditingController passportNoController = TextEditingController();
  TextEditingController nationalIDNoController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController nationalCardIDNoController = TextEditingController();
  TextEditingController messageToUsController = TextEditingController();

  Future<void> _setMyTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyTheme> themes = [];

    final encodedThemeData = prefs.getString('appTheme');
    if (encodedThemeData == null) {
      themes = defaultThemes.map((theme) => MyTheme.fromMap(theme)).toList();
    } else {
      var decodedThemeData = json.decode(encodedThemeData);
      themes = (decodedThemeData as List)
          .map((theme) => MyTheme.fromJson(theme))
          .toList();
    }

    setState(() {
      _themes = themes;
    });
  }

  Future<void> fetchMyCustomerInfo() async {
    setState(() {
      isDataLoading['myCusInfo'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    bool isError = false;
    Customer myCusInfo = Customer();
    try {
      final myCusInfoRes = await http.get(
          Uri.parse('$serverDomain/api/customers/me'),
          headers: {'Authorization': 'Bearer $token'});

      if (myCusInfoRes.statusCode == 200) {
        var jsonMyCusInfo = json.decode(myCusInfoRes.body)[0];
        String encodedMyCusInfo =
            json.encode(Customer.fromMap(jsonMyCusInfo[0]));
        print("online-myCusInfo : $encodedMyCusInfo");
        await prefs.setString('myCusInfo', encodedMyCusInfo);
        myCusInfo = Customer.fromMap(jsonMyCusInfo[0]);

        isDataFetched['myCusInfo'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['myCusInfo'] = false;
      final encodedMyCusInfo = prefs.getString('myCusInfo');
      if (encodedMyCusInfo != null && encodedMyCusInfo != "") {
        print("offline-myCusInfo : $encodedMyCusInfo");
        var decodedMyCusInfo = json.decode(encodedMyCusInfo);
        myCusInfo = Customer.fromJson(decodedMyCusInfo);
      }
    }

    setState(() {
      isDataLoading['myCusInfo'] = false;
      stMyCustomerInfo = myCusInfo;
    });
  }

  Future<void> fetchClasses() async {
    setState(() {
      isDataLoading['myClasses'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    bool isError = false;
    List<Class> classes = [];
    try {
      final classesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myclasses'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonClasses = json.decode(classesRes.body)[0];
      if (classesRes.statusCode == 200) {
        classes = (jsonClasses as List)
            .map((myclass) => Class.fromMap(myclass))
            .toList();
        String encodedClasses = json.encode(classes);
        print("online-Classes : $encodedClasses");
        await prefs.setString('myClasses', encodedClasses);
        isDataFetched['myClasses'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['myClasses'] = false;
      final encodedClasses = prefs.getString('myClasses');
      if (encodedClasses != null && encodedClasses != "") {
        print("offline-Classes : $encodedClasses");
        var decodedClasses = json.decode(encodedClasses);
        classes = (decodedClasses as List)
            .map((classe) => Class.fromJson(classe))
            .toList();
      }
    }

    setState(() {
      isDataLoading['myClasses'] = false;
      stClasses = classes;
    });
  }

  Future<void> fetchCourses() async {
    setState(() {
      isDataLoading['myCourses'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    bool isError = false;
    List<Course> myCourses = [];
    try {
      final myCoursesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/mine'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonMyCourses = json.decode(myCoursesRes.body)[0];
      if (myCoursesRes.statusCode == 200) {
        myCourses = (jsonMyCourses as List)
            .map((course) => Course.fromMap(course))
            .toList();
        String encodedMyCourses = json.encode(myCourses);
        print("online-Courses : $encodedMyCourses");
        await prefs.setString('myCourses', encodedMyCourses);
        isDataFetched['myCourses'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['myCourses'] = false;
      final encodedMyCourses = prefs.getString('myCourses');
      if (encodedMyCourses != null && encodedMyCourses != "") {
        print("offline-Courses : $encodedMyCourses");
        var decodedCourses = json.decode(encodedMyCourses);
        myCourses = (decodedCourses as List)
            .map((course) => Course.fromJson(course))
            .toList();
      }
    }

    setState(() {
      isDataLoading['myCourses'] = false;
      stCourses = myCourses;
    });
  }

  Future<void> fetchResources() async {
    setState(() {
      isDataLoading['resources'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");

    bool isError = false;
    List<Resource> resources = [];

    try {
      final resourcesRes = await http.get(
          Uri.parse('$serverDomain/api/courses/myresources'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonResources = json.decode(resourcesRes.body)[0];
      if (resourcesRes.statusCode == 200) {
        resources = (jsonResources as List)
            .map((resource) => Resource.fromMap(resource))
            .toList();
        String encodedResources = json.encode(resources);
        print("online-Resources : $encodedResources");
        await prefs.setString('resources', encodedResources);
        isDataFetched['resources'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['resources'] = false;
      final encodedResources = prefs.getString('resources');
      if (encodedResources != null && encodedResources != "") {
        print("offline-Resources : $encodedResources");
        var decodedResources = json.decode(encodedResources);
        resources = (decodedResources as List)
            .map((resource) => Resource.fromJson(resource))
            .toList();
      }
    }

    setState(() {
      isDataLoading['resources'] = false;
      stResources = resources;
    });
  }

  Future<void> fetchStudents(int courseID) async {
    setState(() {
      isDataLoading['students'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    bool isError = false;
    List<Customer> students = [];
    try {
      final response = await http.get(
          Uri.parse('$serverDomain/api/courses/allstudents/$courseID'),
          headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        var jsonStudents = json.decode(response.body)[0];
        students = (jsonStudents as List)
            .map((myMap) => Customer.fromMap(myMap))
            .toList();
        String encodedStudents = json.encode(students);
        print("online-Students/$courseID : $encodedStudents");
        await prefs.setString('students/$courseID', encodedStudents);
        isDataFetched['students/$courseID'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['students/$courseID'] = false;
      final encodedStudents = prefs.getString('students/$courseID');
      if (encodedStudents != null && encodedStudents != "") {
        print("offline-Students/$courseID : $encodedStudents");
        var decodedStudents = json.decode(encodedStudents);
        students = (decodedStudents as List)
            .map((student) => Customer.fromJson(student))
            .toList();
      }
    }

    setState(() {
      isDataLoading['students'] = false;
      stStudentsByCourseID['students/$courseID'] = students;
    });
  }

  Future<void> fetchSoas() async {
    setState(() {
      isDataLoading['soas'] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic token = prefs.getString("jwt");

    bool isError = false;
    List<SOA> soas = [];
    try {
      final soaRes = await http.get(
          Uri.parse('$serverDomain/api/customers/mysoa'),
          headers: {'Authorization': 'Bearer $token'});

      var jsonSoas = json.decode(soaRes.body)[0];
      if (soaRes.statusCode == 200) {
        soas = (jsonSoas as List).map((myMap) => SOA.fromMap(myMap)).toList();
        String encodedSoas = json.encode(soas);
        print("online-Soas : $encodedSoas");
        await prefs.setString('soas', encodedSoas);
        isDataFetched['soas'] = true;
      } else {
        isError = true;
      }
    } catch (e) {
      isError = true;
    }

    if (isError) {
      isDataFetched['soas'] = false;
      final encodedSoas = prefs.getString('soas');
      if (encodedSoas != null && encodedSoas != "") {
        print("offline-Soas : $encodedSoas");
        var decodedSoas = json.decode(encodedSoas);
        soas = (decodedSoas as List).map((soa) => SOA.fromJson(soa)).toList();
      }
    }

    setState(() {
      isDataLoading['soas'] = false;
      stSoas = soas;
    });
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

  Future<void> addClass(
    int? classID,
    String sessionDateTime,
    String sessionStartingTime,
    int sessionDuration,
    int sessionUpdatedBy,
  ) async {
    String url = "$serverDomain/api/courses/addclass";
    Map body = {
      "classID": _activeClassID  ?? -1,
      "sessionDateTime": sessionDateTime,
      "sessionStartingTime": sessionStartingTime,
      "sessionDuration": sessionDuration,
      "sessionStatusID": 1,
      "sessionDeliveryStatusID": 6,
      "sessionUpdatedBy": sessionUpdatedBy,
    };
    print(body);
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
      fetchMyCustomerInfo();
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

  Future<void> _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _refreshPage() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () async {
      await Future.wait([
        fetchMyCustomerInfo(),
        fetchClasses(),
        fetchCourses(),
        fetchResources(),
        fetchSoas(),
      ]);
      setState(() {
        _isLoading = false;
        _activePageIdx = 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _pageTrack.add(0);

    _setMyTheme();
    Future.wait([
      fetchMyCustomerInfo(),
      fetchClasses(),
    ]);
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
    };

    return WillPopScope(
        onWillPop: () async {
          if (_pageTrack.length > 1) {
            _pageTrack.removeLast();
            setState(() {
              _activePageIdx = _pageTrack.last;
            });
            return false; // prevent app from closing
          }
          return true; // close the app
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
                    child: Column(
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.only(top: 40.0, bottom: 0),
                      child: Text(
                        "اخرین بروز رسانی",
                        style: TextStyle(
                          fontSize: 15,
                          color: convertHexToColor(_themes[2].labelFontColor!),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.only(top: 2.0, bottom: 0),
                      child: Text(
                        // "25-4-2022 15:30",
                        DateFormat('dd-MM-yyyy hh:mm').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 12,
                          color: convertHexToColor(_themes[2].datafontColor!),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    )
                  ],
                )),
                Expanded(
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
                              })
                            }
                        },
                        icon: stMyCustomerInfo.profilePhotoWebAddress!.isEmpty
                            ? IconTheme(
                                data: IconThemeData(
                                  color: convertHexToColor(
                                      _themes[2].labelFontColor!),
                                  size: 21,
                                ),
                                child: const Icon(Icons.person))
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    stMyCustomerInfo.profilePhotoWebAddress!),
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
              isNotified: index == 2,
              color: convertHexToColor(_themes[4].labelFontColor!),
              activeColor: convertHexToColor(_themes[4].datafontColor!),
              onTap: () {
            if (index == 3) {
              _refreshPage();
            } else {
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
    List<Class> todayNextClasses = getClassesByCourseID(stClasses, -3);
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                        fetchCourses();
                      }
                    } else {
                      fetchCourses();
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
                        fetchSoas();
                      }
                    } else {
                      fetchSoas();
                    }
                    setState(() {
                      _activePageIdx = 12;
                      _pageTrack.add(12);
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

  Widget _buildContactUsPage() {
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                ...List.generate(
                  _messageList.length,
                  (index) => SubPageListItem(
                    subListType: SubPageListType.chatMessage,
                    messageDate: _messageList[index].sentAt,
                    messageContent: _messageList[index].message,
                    // messageSender: _messageList[index].senderID ==
                    //         _myCustomerInfo.registerID
                    //     ? "شما"
                    //     : _messageList[index].senderID == 5
                    //         ? "مرکز"
                    //         : "unknown",
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    dataColor: convertHexToColor(_themes[0].datafontColor!),
                  ),
                ),
              ],
            ),
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
                    color: convertHexToColor(_themes[1].datafontColor!),
                  ),
                  decoration: InputDecoration(
                      hintText: 'پیغام:',
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
                  // signIn(usernameController.text, passwordController.text);
                  if (messageToUsController.text.isNotEmpty) {
                    // _sendMessage(messageToUsController.text);
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
    return Column(
      children: [
        SubPageHeaderSection(
          title: "علان ها",
          icon: Icons.notifications,
          isRotate: true,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
        ),
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                  LastNotificationSection(
                    message: "تا پایان 21 جون مهلت تسویه حساب",
                    receivedDate: DateTime(2022, 4, 25, 15, 30),
                    bgColor: const Color(0xFF333F50),
                    notificationColor:
                        convertHexToColor(_themes[0].datafontColor!),
                    labelColor: convertHexToColor(_themes[0].labelFontColor!),
                    isLastMsg: false,
                  ),
                ],
              )),
        ), // Main Page
      ],
    );
  }

  Widget _buildRefreshPage() {
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                        fetchResources();
                      }
                    } else {
                      fetchResources();
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
                        fetchStudents(courseID);
                      }
                    } else {
                      fetchStudents(courseID);
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
    List<Class> myClasses =
        getClassesByCourseID(stClasses, _activeCourse.courseID!);
    _activeClassID = myClasses.isNotEmpty ? myClasses[0].classID : -1;
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
            if (_activeClassID == -1) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Couldn't create class for this course",
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
    List<Class> classes = getClassesByCourseID(stClasses, -1);
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
    List<Class> classes =
        getClassesByCourseID(stClasses, _activeCourse.courseID!);
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                : classes.isNotEmpty
                    ? Column(
                        children: [
                          ...List.generate(
                            classes.length,
                            (index) => SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SubPageListItem(
                                subListType: SubPageListType.recordedClasses,
                                recordClassScreen:
                                    "assets/images/record_class.png",
                                recordDuration: classes[index].sessionDuration,
                                icon: Icons.camera,
                                svgIcon: "assets/images/record.svg",
                                labelColor: convertHexToColor(
                                    _themes[0].labelFontColor!),
                                dataColor: convertHexToColor(
                                    _themes[0].datafontColor!),
                                onLinkRecordClass: () async {
                                  final uri = Uri.parse(
                                      classes[index].sessionRecodingWebLink!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    throw 'Could not launch';
                                  }
                                },
                              ),
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

  Widget _buildStudyResourcesPage() {
    List<Resource> resources =
        getResourcesByCourseID(stResources, _activeCourse.courseID!);
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
          bgColor: convertHexToColor(_themes[3].bgColor!),
          notificationColor: convertHexToColor(_themes[3].datafontColor!),
          labelColor: convertHexToColor(_themes[3].labelFontColor!),
        ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.studentsList,
          title: "اسامی دانشجویان",
          icon: Icons.person,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
          onClickSendMsgToALlStudents: () {
            setState(() {
              _activePageIdx = 15;
              _pageTrack.add(15);
            });
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                          "مانده",
                          style: TextStyle(
                            color: convertHexToColor(_themes[0].datafontColor!),
                            fontSize: 18,
                          ),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          stSoas.isNotEmpty
                              ? "${stSoas[stSoas.length - 1].netTotalAmount} Euro"
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
          bgColor: convertHexToColor(_themes[3].bgColor!),
          notificationColor: convertHexToColor(_themes[3].datafontColor!),
          labelColor: convertHexToColor(_themes[3].labelFontColor!),
        ),
        SubPageHeaderSection(
          headerType: SubPageHeaderType.addClass,
          title: "کلاس جدید",
          courseName: "روانشناسی سلامت",
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
                              hintText: "تاریخ:",
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
                            final now = DateTime.now();
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
                          _sessionDateTime.toString(),
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                      "Joining the class instruction text",
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
              final uri = Uri.parse(_activeClass.sessionWebLink!);
              // final uri = Uri.parse("https://time.is/United_Arab_Emirates");
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch';
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
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
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
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.bottom,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                            decoration: InputDecoration(
                                hintText: "لاحظ بعض النص ...",
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
              setState(() {
                _activePageIdx = 10;
                _pageTrack.add(10);
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 35.0,
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
    emailController.text = stMyCustomerInfo.email ?? "";
    countryCodeController.text = "+98";
    contactNumberController.text = stMyCustomerInfo.contactNumber ?? "";
    residentCountryIDController.text =
        stMyCustomerInfo.residentCountryID.toString();
    passportNoController.text = stMyCustomerInfo.passportNo ?? "";
    nationalIDNoController.text = stMyCustomerInfo.nationalIDNo ?? "";
    dateOfBirthController.text = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(stMyCustomerInfo.dateOfBirth!));
    nationalCardIDNoController.text = stMyCustomerInfo.nationalCardIDNo ?? "";
    return Column(
      children: [
        LastNotificationSection(
          message: "تا پایان 21 جون مهلت تسویه حساب",
          receivedDate: DateTime(2022, 4, 25, 15, 30),
          bgColor: convertHexToColor(_themes[3].bgColor!),
          notificationColor: convertHexToColor(_themes[3].datafontColor!),
          labelColor: convertHexToColor(_themes[3].labelFontColor!),
        ),
        SubPageHeaderSection(
          title: "اطلاعات شخصی",
          headerType: SubPageHeaderType.profile,
          // avatarImage: _avatarImage,
          avatarAddress: stMyCustomerInfo.profilePhotoWebAddress,
          labelColor: convertHexToColor(_themes[0].labelFontColor!),
          dataColor: convertHexToColor(_themes[0].datafontColor!),
          // onHeaderIconClicked: _handleAvatarUploadButtonPressed,
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
                              hintText: ':ایمیل',
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
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                              hintText: 'Phone number with prefix code..',
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
                          color: Colors.white,
                          child: DropdownButton<String>(
                            value: _selectedCountry,
                            isExpanded: true,
                            items: countryCodes.map((Map<String, String> item) {
                              return DropdownMenuItem<String>(
                                value: item['country'],
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${item['country']}",
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ]),
                              );
                            }).toList(),
                            underline: Container(),
                            onChanged: (String? selectedItem) {
                              setState(() {
                                _selectedCountry = selectedItem ?? "United Arab Emirates";
                              });
                            },
                            style: const TextStyle(
                              fontSize:16,
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
                          hintText: ':شماره پاسپورت',
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
                          hintText: ':شماره شناسه ملی',
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
                          ':شماره شناسه ملی',
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
                          hintText: ':روز تولد',
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
                          ':روز تولد',
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
                          hintText: ':شماره کارت ملی',
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
                        "residentCountryID":
                            int.parse(residentCountryIDController.text),
                        "passportNo": passportNoController.text,
                        "nationalIDNo": nationalIDNoController.text,
                        "dateOfBirth": _dateOfBirth.toString(),
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
}
