import 'dart:convert';

class AdminOrganisasiResponseModel {
  final String message;
  final OrganisasiData data;

  AdminOrganisasiResponseModel({required this.message, required this.data});

  factory AdminOrganisasiResponseModel.fromJson(String str) =>
      AdminOrganisasiResponseModel.fromMap(json.decode(str));

  factory AdminOrganisasiResponseModel.fromMap(Map<String, dynamic> json) =>
      AdminOrganisasiResponseModel(
        message: json['message'] ?? '',
        data: OrganisasiData.fromMap(json['data']),
      );

  Map<String, dynamic> toMap() => {"message": message, "data": data.toMap()};

  String toJson() => json.encode(toMap());
}

class OrganisasiData {
  final int id;
  final String username;
  final String email;
  final int roleId;
  final String? createdAt;
  final String? updatedAt;

  OrganisasiData({
    required this.id,
    required this.username,
    required this.email,
    required this.roleId,
    this.createdAt,
    this.updatedAt,
  });

  OrganisasiData copyWith({
    int? id,
    String? username,
    String? email,
    int? roleId,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrganisasiData(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OrganisasiData.fromMap(Map<String, dynamic> json) => OrganisasiData(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    roleId: json['role_id'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "username": username,
    "email": email,
    "role_id": roleId,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };

  static List<OrganisasiData> fromList(List<dynamic> json) =>
      json.map((e) => OrganisasiData.fromMap(e)).toList();
}
