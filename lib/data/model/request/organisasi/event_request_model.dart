import 'dart:convert';

class EventRequestModel {
  final String nama;
  final String deskripsi;
  final String tglBuka;
  final String tglTutup;
  final int kuotaMahasiswa;
  final String? alamat;
  final String? photo;

  EventRequestModel({
    required this.nama,
    required this.deskripsi,
    required this.tglBuka,
    required this.tglTutup,
    required this.kuotaMahasiswa,
    this.alamat,
    this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'tgl_buka': tglBuka,
      'tgl_tutup': tglTutup,
      'kuota_mahasiswa': kuotaMahasiswa,
      if (alamat != null) 'alamat': alamat,
      if (photo != null) 'photo': photo,
    };
  }

  String toJson() => json.encode(toMap());

  factory EventRequestModel.fromMap(Map<String, dynamic> map) {
    return EventRequestModel(
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tglBuka: map['tgl_buka'] ?? '',
      tglTutup: map['tgl_tutup'] ?? '',
      kuotaMahasiswa: map['kuota_mahasiswa']?.toInt() ?? 0,
      alamat: map['alamat'],
      photo: map['photo'],
    );
  }

  factory EventRequestModel.fromJson(String source) =>
      EventRequestModel.fromMap(json.decode(source));
}
