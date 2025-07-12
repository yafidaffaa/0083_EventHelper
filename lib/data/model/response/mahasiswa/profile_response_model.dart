import 'dart:convert';

class MahasiswaProfileResponseModel {
  final int id;
  final int userId;
  final String nama;
  final String nim;
  final String prodi;
  final String angkatan;
  final DateTime createdAt;
  final DateTime updatedAt;

  MahasiswaProfileResponseModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.angkatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MahasiswaProfileResponseModel.fromMap(Map<String, dynamic> map) {
    return MahasiswaProfileResponseModel(
      id: map['id'],
      userId: map['user_id'],
      nama: map['nama'],
      nim: map['nim'],
      prodi: map['prodi'],
      angkatan: map['angkatan'],
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

  factory MahasiswaProfileResponseModel.fromJson(String source) =>
      MahasiswaProfileResponseModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'nama': nama,
    'nim': nim,
    'prodi': prodi,
    'angkatan': angkatan,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String toJson() => json.encode(toMap());
}
