import 'dart:convert';

class Class {
  int? customerID;
  String? cutomerContact;
  String? customerEmail;
  int? studyYear;
  int? courseID;
  int? courseCode;
  String? courseDescription;
  int? studyYearID;
  int? classID;
  String? sessionStatusDescription;
  int? sessionStatusID;
  String? sessionDateTime;
  int? sessionDuration;
  String? sessionNote;
  int? sessionDeliveryStatusID;
  String? sessionRecodingWebLink;
  String? sessionWebLink;
  int? TeacherCustomerID;
  String? TeacherFirstName;
  String? TeacherLastName;
  String? TeacherEmail;
  String? TeacherContact;
  int? registerID;
  String? classNote;
  String? classTitle;
  String? classDescription;
  String? timeZone;
  String? languageDescription;
  int? languageOfTheClassID;
  bool? writingDirectionRtoL;
  int? classTypeID;
  String? classTypeDescription;
  String? studyLevelDescription;
  String? fieldOfStudyDescription;

  Class(
      { this.customerID = 0,
        this.cutomerContact = "",
        this.customerEmail = "",
        this.studyYear = 0,
        this.courseID = 0,
        this.courseCode = 0,
        this.courseDescription = "",
        this.studyYearID = 0,
        this.classID = 0,
        this.sessionStatusDescription = "",
        this.sessionStatusID = 0,
        this.sessionDateTime = "",
        this.sessionDuration = 0,
        this.sessionNote = "",
        this.sessionDeliveryStatusID = 0,
        this.sessionRecodingWebLink = "",
        this.sessionWebLink = "",
        this.TeacherCustomerID = 0,
        this.TeacherFirstName = "",
        this.TeacherLastName = "",
        this.TeacherEmail = "",
        this.TeacherContact = "",
        this.registerID = 0,
        this.classNote = "",
        this.classTitle = "",
        this.classDescription = "",
        this.timeZone = "",
        this.languageDescription = "",
        this.languageOfTheClassID = 0,
        bool? writingDirectionRtoL = false,
        this.classTypeID = 0,
        this.classTypeDescription = "",
        this.studyLevelDescription = "",
        this.fieldOfStudyDescription = "",
      });

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      customerID: map['customerID'],
      cutomerContact: map['cutomerContact'],
      customerEmail: map['customerEmail'],
      studyYear: map['studyYear'],
      courseID: map['courseID'],
      courseCode: map['courseCode'],
      courseDescription: map['courseDescription'],
      studyYearID: map['studyYearID'],
      classID: map['classID'],
      sessionStatusDescription: map['sessionStatusDescription'],
      sessionStatusID: map['sessionStatusID'],
      sessionDateTime: map['sessionDateTime'],
      sessionDuration: map['sessionDuration'],
      sessionNote: map['sessionNote'],
      sessionDeliveryStatusID: map['sessionDeliveryStatusID'],
      sessionRecodingWebLink: map['sessionRecodingWebLink'],
      sessionWebLink: map['sessionWebLink'],
      TeacherCustomerID: map['TeacherCustomerID'],
      TeacherFirstName: map['TeacherFirstName'],
      TeacherLastName: map['TeacherLastName'],
      TeacherEmail: map['TeacherEmail'],
      TeacherContact: map['TeacherContact'],
      registerID: map['registerID'],
      classNote: map['classNote'],
      classTitle: map['classTitle'],
      classDescription: map['classDescription'],
      timeZone: map['timeZone'],
      languageDescription: map['languageDescription'],
      languageOfTheClassID: map['languageOfTheClassID'],
      writingDirectionRtoL: map['writingDirectionRtoL'],
      classTypeID: map['classTypeID'],
      classTypeDescription: map['classTypeDescription'],
      studyLevelDescription: map['studyLevelDescription'],
      fieldOfStudyDescription: map['fieldOfStudyDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerID': customerID,
      'cutomerContact': cutomerContact,
      'customerEmail': customerEmail,
      'studyYear': studyYear,
      'courseID': courseID,
      'courseCode': courseCode,
      'courseDescription': courseDescription,
      'studyYearID': studyYearID,
      'classID': classID,
      'sessionStatusDescription': sessionStatusDescription,
      'sessionStatusID': sessionStatusID,
      'sessionDateTime': sessionDateTime,
      'sessionDuration': sessionDuration,
      'sessionNote': sessionNote,
      'sessionDeliveryStatusID': sessionDeliveryStatusID,
      'sessionRecodingWebLink': sessionRecodingWebLink,
      'sessionWebLink': sessionWebLink,
      'TeacherCustomerID': TeacherCustomerID,
      'TeacherFirstName': TeacherFirstName,
      'TeacherLastName': TeacherLastName,
      'TeacherEmail': TeacherEmail,
      'TeacherContact': TeacherContact,
      'registerID': registerID,
      'classNote': classNote,
      'classTitle': classTitle,
      'classDescription': classDescription,
      'timeZone': timeZone,
      'languageDescription': languageDescription,
      'languageOfTheClassID': languageOfTheClassID,
      'writingDirectionRtoL': writingDirectionRtoL,
      'classTypeID': classTypeID,
      'classTypeDescription': classTypeDescription,
      'studyLevelDescription': studyLevelDescription,
      'fieldOfStudyDescription': fieldOfStudyDescription,
    };
  }

  String toJson() => json.encode(toMap());

  factory Class.fromJson(String source) => Class.fromMap(json.decode(source));
}