import 'dart:convert';

class Resource {
  int customerID;
  int courseID;
  int courseResourceID;
  int courseCode;
  int studyYearID;
  String? resourceDescription;
  String? resourceNote;
  String? resourcePublisher;
  String? courseDescription;
  int RegisterID;

  Resource({
    this.customerID = 0,
    this.courseID = 0,
    this.courseResourceID= 0,
    this.courseCode = 0,
    this.studyYearID = 0,
    this.resourceDescription = "",
    this.resourceNote = "",
    this.resourcePublisher = "",
    this.courseDescription = "",
    required this.RegisterID,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
        customerID: map['customerID'],
        courseID: map['courseID'],
        courseResourceID: map['courseResourceID'],
        courseCode: map['courseCode'],
        studyYearID: map['studyYearID'],
        resourceDescription: map['resourceDescription'] ?? "",
        resourceNote: map['resourceNote'] ?? "",
        resourcePublisher: map['resourcePublisher'] ?? "",
        courseDescription: map['courseDescription'] ?? "",
        RegisterID: map['RegisterID']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "customerID": customerID,
      "courseID": courseID,
      "courseResourceID": courseResourceID,
      "courseCode": courseCode,
      "studyYearID": studyYearID,
      "resourceDescription": resourceDescription,
      "resourceNote": resourceNote,
      "resourcePublisher": resourcePublisher,
      "courseDescription": courseDescription,
      "RegisterID": RegisterID
    };
  }

  String toJson() => json.encode(toMap());

  factory Resource.fromJson(String source) => Resource.fromMap(json.decode(source));
}