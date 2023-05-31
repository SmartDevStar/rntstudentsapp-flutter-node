import 'dart:convert';

class SOA {
  int customerID;
  String transactionDate;
  int transactionID;
  dynamic netTotalAmount;
  String type;
  int RegisterID;

  SOA({
    this.customerID = 0,
    this.transactionDate = "",
    this.transactionID = 0,
    this.netTotalAmount = 0,
    this.type = "",
    required this.RegisterID,
  });

  factory SOA.fromMap(Map<String, dynamic> map) {
    return SOA(
        customerID: map['customerID'],
        transactionDate: map['transactionDate'] ?? "",
        transactionID: map['transactionID'],
        netTotalAmount: map['netTotalAmount'],
        type: map['type'] ?? "",
        RegisterID: map['RegisterID']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "customerID": customerID,
      "transactionDate": transactionDate,
      "transactionID": transactionID,
      "netTotalAmount": netTotalAmount,
      "type": type,
      "RegisterID": RegisterID
    };
  }

  String toJson() => json.encode(toMap());

  factory SOA.fromJson(String source) => SOA.fromMap(json.decode(source));
}