import 'dart:convert';

class Customer {
  int? customerID;
  String? customerCode;
  String? FirstName;
  String? LastName;
  String? CustomerTypeDescription;
  int? customerTypeID;
  String? studyLevelDescription;
  int? studyLevelID;
  String? fieldOfStudyDescription;
  int? fieldOfStudyID;
  String? OrganizationDescription;
  int? organizationID;
  String? email;
  String? contactNumber;
  String? passportNo;
  String? nationalIDNo;
  String? dateOfBirth;
  String? nationalCardIDNo;
  int? residentCountryID;
  String? subFiledOfStudyDescription;
  int? subFieldOfStudyID;
  int? studyStatusID;
  int? studyOrganizationID;
  String? studyStatusDescription;
  String? countryName;
  int? nationalityCountryID;
  int registerID;
  int RegisterID;
  String? loginEmailAddress;
  bool? inActive;
  bool? onHold;
  String? profilePhotoWebAddress;
  String? englishFirstName;
  String? englishLastName;
  String? fieldOfStudyDescriptionEnglish;

  Customer({
    this.customerID = 0,
    this.customerCode = "",
    this.FirstName = "",
    this.LastName = "",
    this.CustomerTypeDescription = "",
    this.customerTypeID = 0,
    this.studyLevelDescription = "",
    this.studyLevelID = 0,
    this.fieldOfStudyDescription = "",
    this.fieldOfStudyID = 0,
    this.OrganizationDescription = "",
    this.organizationID = 0,
    this.email = "",
    this.contactNumber = "",
    this.passportNo = "",
    this.nationalIDNo = "",
    this.dateOfBirth = "1990-01-01 00:00:00.000",
    this.nationalCardIDNo = "",
    this.residentCountryID = 0,
    this.subFiledOfStudyDescription = "",
    this.subFieldOfStudyID = 0,
    this.studyStatusID = 0,
    this.studyOrganizationID = 0,
    this.studyStatusDescription = "",
    this.countryName = "",
    this.nationalityCountryID = 0,
    this.inActive = false,
    this.onHold = false,
    this.registerID = 0,
    this.RegisterID = 0,
    this.loginEmailAddress = "",
    this.profilePhotoWebAddress = "",
    this.englishFirstName = "",
    this.englishLastName = "",
    this.fieldOfStudyDescriptionEnglish = "",
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      customerID: map['customerID'],
      customerCode: map['customerCode'],
      FirstName: map['FirstName'],
      LastName: map['LastName'],
      CustomerTypeDescription: map['CustomerTypeDescription'] ?? "",
      customerTypeID: map['customerTypeID'] ?? 0,
      studyLevelDescription: map['studyLevelDescription'] ?? "",
      studyLevelID: map['studyLevelID'] ?? 0,
      fieldOfStudyDescription: map['fieldOfStudyDescription'] ?? "",
      fieldOfStudyID: map['fieldOfStudyID'] ?? 0,
      OrganizationDescription: map['OrganizationDescription'] ?? "",
      organizationID: map['organizationID'] ?? 0,
      email: map['email'] ?? "---",
      contactNumber: map['contactNumber'] ?? "",
      passportNo: map['passportNo'] ?? "",
      nationalIDNo: map['nationalIDNo'] ?? "",
      dateOfBirth: map['dateOfBirth'] ?? "",
      nationalCardIDNo: map['nationalCardIDNo'] ?? "",
      residentCountryID: map['residentCountryID'] ?? 0,
      subFiledOfStudyDescription: map['subFiledOfStudyDescription'] ?? "",
      subFieldOfStudyID: map['subFieldOfStudyID'] ?? 0,
      studyStatusID: map['studyStatusID'] ?? 0,
      studyOrganizationID: map['studyOrganizationID'] ?? 0,
      studyStatusDescription: map['studyStatusDescription'] ?? "",
      countryName: map['countryName'] ?? "",
      nationalityCountryID: map['nationalityCountryID'] ?? 0,
      inActive: map['inActive'] ?? false,
      onHold: map['onHold'] ?? false,
      registerID: map['registerID'] ?? 0,
      RegisterID: map['RegisterID'] ?? 0,
      loginEmailAddress: map['loginEmailAddress'] ?? "",
      profilePhotoWebAddress: map['profilePhotoWebAddress'] ?? "",
      englishFirstName: map['englishFirstName'] ?? "",
      englishLastName: map['englishLastName'] ?? "",
      fieldOfStudyDescriptionEnglish:
          map['fieldOfStudyDescriptionEnglish'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerID': customerID,
      'customerCode': customerCode,
      'FirstName': FirstName,
      'LastName': LastName,
      'CustomerTypeDescription': CustomerTypeDescription,
      'customerTypeID': customerTypeID,
      'studyLevelDescription': studyLevelDescription,
      'studyLevelID': studyLevelID,
      'fieldOfStudyDescription': fieldOfStudyDescription,
      'fieldOfStudyID': fieldOfStudyID,
      'OrganizationDescription': OrganizationDescription,
      'organizationID': organizationID,
      'email': email,
      'contactNumber': contactNumber,
      'passportNo': passportNo,
      'nationalIDNo': nationalIDNo,
      'dateOfBirth': dateOfBirth,
      'nationalCardIDNo': nationalCardIDNo,
      'residentCountryID': residentCountryID,
      'subFiledOfStudyDescription': subFiledOfStudyDescription,
      'subFieldOfStudyID': subFieldOfStudyID,
      'studyStatusID': studyStatusID,
      'studyOrganizationID': studyOrganizationID,
      'studyStatusDescription': studyStatusDescription,
      'countryName': countryName,
      'nationalityCountryID': nationalityCountryID,
      'inActive': inActive,
      'onHold': onHold,
      'registerID': registerID,
      'RegisterID': RegisterID,
      'loginEmailAddress': loginEmailAddress,
      'profilePhotoWebAddress': profilePhotoWebAddress,
      'englishFirstName': englishFirstName,
      'englishLastName': englishLastName,
      'fieldOfStudyDescriptionEnglish': fieldOfStudyDescriptionEnglish,
    };
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source));
}
