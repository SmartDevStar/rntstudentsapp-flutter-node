import 'dart:convert';

class MyTheme {
  int? objectID;
  int? objectTypeID;
  String? objectTypeDescription;
  String? bgColor;
  String? labelFontColor;
  String? datafontColor;
  String? fileName;
  String? fileData;

  MyTheme(
       {this.objectID,
        this.objectTypeID,
        this.objectTypeDescription,
        this.bgColor,
        this.labelFontColor,
        this.datafontColor,
        this.fileName,
        this.fileData,});

  factory MyTheme.fromMap(Map<String, dynamic> map) {
    return MyTheme(
      objectID: map['objectID'],
      objectTypeID: map['objectTypeID'],
      objectTypeDescription: map['objectTypeDescription'],
      bgColor: map['bgColor'],
      labelFontColor: map['labelFontColor'],
      datafontColor: map['datafontColor'],
      fileName: map['fileName'],
      fileData: map['fileData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'objectID': objectID,
      'objectTypeID': objectTypeID,
      'objectTypeDescription': objectTypeDescription,
      'bgColor': bgColor,
      'labelFontColor': labelFontColor,
      'datafontColor': datafontColor,
      'fileName': fileName,
      'fileData': fileData,
    };
  }

  String toJson() => json.encode(toMap());

  factory MyTheme.fromJson(String source) => MyTheme.fromMap(json.decode(source));
}