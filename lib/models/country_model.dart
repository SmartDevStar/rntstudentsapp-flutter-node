import 'dart:convert';

class Country {
  int countryID;
  String countryName;
  String countryPhoneCode;
  int countryTimeZone;

  Country({
    this.countryID = -1,
    this.countryName = "",
    this.countryPhoneCode = "",
    this.countryTimeZone = -1,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
        countryID: map['countryID'] ?? -1,
        countryName: map['countryName'] ?? "",
        countryPhoneCode: map['countryPhoneCode'] ?? "",
        countryTimeZone: map['countryTimeZone'] ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "countryID": countryID,
      "countryName": countryName,
      "countryPhoneCode": countryPhoneCode,
      "countryTimeZone": countryTimeZone,
    };
  }

  String toJson() => json.encode(toMap());

  factory Country.fromJson(String source) => Country.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) => other is Country && other.countryID == countryID;

  @override
  int get hashCode => countryID.hashCode;
}