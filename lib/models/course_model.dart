import 'dart:convert';

class Course {
  int? customerID;
  String? cutomerContact;
  String? customerEmail;
  int? studyYear;
  int? courseID;
  int? courseCode;
  int? courseTotalUnit;
  int? courseTheoryUnit;
  int? courseNoneTheoryUnit;
  String? courseDescription;
  int? TeachedCustomerID;
  String? TeacherFirstName;
  String? TeacherLastName;
  String? TeacherEmail;
  String? TeacherContact;
  int? registerID;
  bool? isVoided;

  Course(
      { this.customerID = 0,
      this.cutomerContact = "",
      this.customerEmail = "",
      this.studyYear = 0,
      this.courseID = 0,
      this.courseCode = 0,
      this.courseTotalUnit = 0,
      this.courseTheoryUnit = 0,
      this.courseNoneTheoryUnit = 0,
      this.courseDescription = "",
      this.TeachedCustomerID = 0,
      this.TeacherFirstName = "",
      this.TeacherLastName = "",
      this.TeacherEmail = "",
      this.TeacherContact = "",
      this.registerID = 0,
      this.isVoided = false,
      });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      customerID: map['customerID'],
      cutomerContact: map['cutomerContact'],
      customerEmail: map['customerEmail'],
      studyYear: map['studyYear'],
      isVoided: map['isVoided'],
      courseID: map['courseID'],
      courseCode: map['courseCode'],
      courseTotalUnit: map['courseTotalUnit'],
      courseTheoryUnit: map['courseTheoryUnit'],
      courseNoneTheoryUnit: map['courseNoneTheoryUnit'],
      courseDescription: map['courseDescription'],
      TeachedCustomerID: map['TeachedCustomerID'],
      TeacherFirstName: map['TeacherFirstName'],
      TeacherLastName: map['TeacherLastName'],
      TeacherEmail: map['TeacherEmail'],
      TeacherContact: map['TeacherContact'],
      registerID: map['registerID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerID': customerID,
      'cutomerContact': cutomerContact,
      'customerEmail': customerEmail,
      'studyYear': studyYear,
      'isVoided': isVoided,
      'courseID': courseID,
      'courseCode': courseCode,
      'courseTotalUnit': courseTotalUnit,
      'courseTheoryUnit': courseTheoryUnit,
      'courseNoneTheoryUnit': courseNoneTheoryUnit,
      'courseDescription': courseDescription,
      'TeachedCustomerID': TeachedCustomerID,
      'TeacherFirstName': TeacherFirstName,
      'TeacherLastName': TeacherLastName,
      'TeacherEmail': TeacherEmail,
      'TeacherContact': TeacherContact,
      'registerID': registerID,
    };
  }

  String toJson() => json.encode(toMap());

  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}