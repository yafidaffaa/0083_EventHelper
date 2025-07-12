import 'dart:convert';

class AdminOrganisasiRequestModel {
  final String username;
  final String email;
  final String? password;

  AdminOrganisasiRequestModel({
    required this.username,
    required this.email,
    this.password,
  });

  /// Parse dari JSON string
  factory AdminOrganisasiRequestModel.fromJson(String str) =>
      AdminOrganisasiRequestModel.fromMap(json.decode(str));

  /// Parse dari Map
  factory AdminOrganisasiRequestModel.fromMap(Map<String, dynamic> json) =>
      AdminOrganisasiRequestModel(
        username: json['username'],
        email: json['email'],
        password: json['password'],
      );

  /// Ubah ke Map (untuk dikirim via request)
  Map<String, dynamic> toMap() => {
    "username": username,
    "email": email,
    if (password != null) "password": password,
  };

  /// Ubah ke JSON string
  String toJson() => json.encode(toMap());
}
