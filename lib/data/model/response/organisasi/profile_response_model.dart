import 'dart:convert';

class ProfileResponseModel {
  final int id;
  final int userId;
  final String tipe;
  final String nama;
  final String prodi;
  final String fakultas;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileResponseModel({
    required this.id,
    required this.userId,
    required this.tipe,
    required this.nama,
    required this.prodi,
    required this.fakultas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileResponseModel.fromMap(Map<String, dynamic> map) {
    return ProfileResponseModel(
      id: map['id'],
      userId: map['user_id'],
      tipe: map['tipe'],
      nama: map['nama'],
      prodi: map['prodi'],
      fakultas: map['fakultas'],
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  factory ProfileResponseModel.fromJson(String source) =>
      ProfileResponseModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'tipe': tipe,
    'nama': nama,
    'prodi': prodi,
    'fakultas': fakultas,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String toJson() => json.encode(toMap());
}
