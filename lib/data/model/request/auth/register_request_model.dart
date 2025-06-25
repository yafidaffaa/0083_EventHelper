import 'dart:convert';

class RegisterRequestModel {
  final String? username;
  final String? email;
  final String? password;
  final String? passwordConfirmation;

  RegisterRequestModel({
    this.username,
    this.email,
    this.password,
    this.passwordConfirmation,
  });

  factory RegisterRequestModel.fromJson(String str) =>
      RegisterRequestModel.fromMap(json.decode(str));

  Map<String, dynamic> toJson() => toMap();

  factory RegisterRequestModel.fromMap(Map<String, dynamic> json) =>
      RegisterRequestModel(
        username: json["username"],
        email: json["email"],
        password: json["password"],
        passwordConfirmation: json["password_confirmation"],
      );

  Map<String, dynamic> toMap() => {
    "username": username,
    "email": email,
    "password": password,
    "password_confirmation": passwordConfirmation,
  };
}
