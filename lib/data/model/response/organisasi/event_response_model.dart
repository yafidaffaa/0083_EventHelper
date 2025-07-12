import 'dart:convert';

class EventResponseModel {
  final String message;
  final EventData? data;

  EventResponseModel({required this.message, this.data});

  factory EventResponseModel.fromMap(Map<String, dynamic> map) {
    return EventResponseModel(
      message: map['message'] ?? '',
      data: map['data'] != null ? EventData.fromMap(map['data']) : null,
    );
  }

  factory EventResponseModel.fromJson(String source) =>
      EventResponseModel.fromMap(json.decode(source));
}

class EventData {
  final int id;
  final String nama;
  final String deskripsi;
  final String tglBuka;
  final String tglTutup;
  final int kuotaMahasiswa;
  final String? photo;
  final String? alamat;
  final int? userId;

  EventData({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tglBuka,
    required this.tglTutup,
    required this.kuotaMahasiswa,
    this.photo,
    this.alamat,
    this.userId,
  });

  factory EventData.fromMap(Map<String, dynamic> map) {
    return EventData(
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tglBuka: map['tgl_buka'] ?? '',
      tglTutup: map['tgl_tutup'] ?? '',
      kuotaMahasiswa: map['kuota_mahasiswa'] ?? 0,
      photo: map['photo'],
      alamat: map['alamat'],
      userId: map['user_id'],
    );
  }

  factory EventData.fromJson(String source) =>
      EventData.fromMap(json.decode(source));

  static List<EventData> fromList(List<dynamic> list) {
    return list.map((e) => EventData.fromMap(e)).toList();
  }
}
