import 'dart:convert';

class ProfileRequestModel {
  final String tipe;
  final String nama;
  final String prodi;
  final String fakultas;

  ProfileRequestModel({
    required this.tipe,
    required this.nama,
    required this.prodi,
    required this.fakultas,
  });

  /// Digunakan untuk membuat data dari form atau API
  factory ProfileRequestModel.fromMap(Map<String, dynamic> map) {
    return ProfileRequestModel(
      tipe: map['tipe'] ?? 'organisasi',
      nama: map['nama'] ?? '',
      prodi: map['prodi'] ?? '',
      fakultas: map['fakultas'] ?? '',
    );
  }

  /// Digunakan untuk mengirim data ke backend (baik create atau update)
  Map<String, dynamic> toMap() {
    return {'tipe': tipe, 'nama': nama, 'prodi': prodi, 'fakultas': fakultas};
  }

  String toJson() => json.encode(toMap());

  factory ProfileRequestModel.fromJson(String source) =>
      ProfileRequestModel.fromMap(json.decode(source));
}
