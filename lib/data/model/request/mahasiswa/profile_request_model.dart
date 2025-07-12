import 'dart:convert';

class MahasiswaProfileRequestModel {
  final String nama;
  final String nim;
  final String prodi;
  final String angkatan;

  MahasiswaProfileRequestModel({
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.angkatan,
  });

  factory MahasiswaProfileRequestModel.fromMap(Map<String, dynamic> map) {
    return MahasiswaProfileRequestModel(
      nama: map['nama'] ?? '',
      nim: map['nim'] ?? '',
      prodi: map['prodi'] ?? '',
      angkatan: map['angkatan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'nama': nama,
    'nim': nim,
    'prodi': prodi,
    'angkatan': angkatan,
  };

  String toJson() => json.encode(toMap());

  factory MahasiswaProfileRequestModel.fromJson(String source) =>
      MahasiswaProfileRequestModel.fromMap(json.decode(source));
}
