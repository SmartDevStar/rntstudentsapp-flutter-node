import 'dart:convert';

class User {
  String? name;
  String? username;
  String? loginEmailaddress;

  User({this.name, this.username, this.loginEmailaddress,});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      username: map['username'],
      loginEmailaddress: map['loginEmailaddress'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'loginEmailaddress': loginEmailaddress,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}