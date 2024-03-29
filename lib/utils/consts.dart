import 'package:flutter/material.dart';

String serverDomain = "http://pnuglobal.dyndns.org:9001";

List<IconData> tapIcons = [
  Icons.home,
  Icons.person,
  Icons.notifications,
  Icons.refresh
];

List<String> tapLabels = ["صفحه اصلی", "ارتباط با ما", "اعلان ها", "تازه سازی"];

List<String> pageNames = [
  "Home",
  "ContactUs",
  "Notification",
  "Refresh",
  "MyCourses",
  "CourseDetail",
  "MyClassSchedule",
  "AllClassSchedule",
  "StudyResources",
  "RecordedClasses",
  "StudentsList",
  "TodayClasses",
  "FinancialStatement",
  "AddNewClass",
  "JoinClass",
  "SendMsgToAllStudents",
  "Profile",
  "UploadDocuments",
];

enum SubPages {
  main,
  myCourses,
  courseDetail,
  myClassSchedule,
  addClass,
  studyResources,
  recordedClasses,
  studentsList,
  sendMsgToAllStudents,
  allClassSchedule,
  joinClass,
  financialStatement,
  chatWithUs,
  notifications,
  refresh
}

enum SubPageListType {
  normal,
  myCourses,
  classSchedule,
  todayClasses,
  studyResources,
  recordedClasses,
  studentsList,
  joinClass,
  financialStatement,
  chatMessage,
  notifications,
}

enum SubPageHeaderType {
  normal,
  courseDetail,
  myClassSchedule,
  addClass,
  studyResources,
  studentsList,
  profile,
}

List<String> classStates = [
  "برگذار شد",
  "برگذار نشد",
  "طبق برنامه",
  "طبق برنامه",
  "طبق برنامه",
  "طبق برنامه",
  "طبق برنامه",
  "طبق برنامه",
  "طبق برنامه",
];

List<Color> colorOfClassStates = [
  const Color(0xff00ff00),
  const Color(0xffffc000),
  const Color(0xffff0000),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
  const Color(0xff00ff00),
];

List<Map<String, String>> countryCodes = [
  {'country': 'United Arab Emirates', 'countryCode': '+971'},
  {'country': 'Norway', 'countryCode': '+47'},
  {'country': 'Chile', 'countryCode': '+56'},
];

final Map<String, String> mimeTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'svg': 'image/svg+xml',
  'bmp': 'image/bmp',
  'tiff': 'image/tiff',
  'pdf': 'application/pdf',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'doc': 'application/msword',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};
