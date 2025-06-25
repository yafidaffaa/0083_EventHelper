import 'dart:convert';

class LoginResponseModel {
  final String? message;
  final String? token;
  final User? user;

  LoginResponseModel({this.message, this.token, this.user});

  factory LoginResponseModel.fromJson(String str) =>
      LoginResponseModel.fromMap(json.decode(str));

  factory LoginResponseModel.fromMap(Map<String, dynamic> json) =>
      LoginResponseModel(
        message: json["message"],
        token: json["token"],
        user: json["user"] == null ? null : User.fromMap(json["user"]),
      );

  Map<String, dynamic> toMap() => {
    "message": message,
    "token": token,
    "user": user?.toMap(),
  };
}

//

class User {
  final int? id;
  final String? username;
  final String? email;
  final int? roleId;
  final String? token; // opsional, jika token disisipkan ke user

  User({this.id, this.username, this.email, this.roleId, this.token});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    roleId: json["role_id"],
    token: json["token"], // hanya jika token ada di sini
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "username": username,
    "email": email,
    "role_id": roleId,
    "token": token,
  };
}
