import 'dart:convert';

class PendaftaranStatusRequestModel {
  final String status;
  final String alasan;

  PendaftaranStatusRequestModel({required this.status, required this.alasan});

  /// Ubah ke Map untuk dikirim ke backend
  Map<String, dynamic> toMap() {
    return {'status': status, 'alasan': alasan};
  }

  /// Ubah ke JSON String (jika dibutuhkan)
  String toJson() => json.encode(toMap());

  /// Buat dari Map (jika dibutuhkan saat parsing)
  factory PendaftaranStatusRequestModel.fromMap(Map<String, dynamic> map) {
    return PendaftaranStatusRequestModel(
      status: map['status'] ?? '',
      alasan: map['alasan'] ?? '',
    );
  }

  /// Buat dari JSON String (jika dibutuhkan saat parsing)
  factory PendaftaranStatusRequestModel.fromJson(String source) =>
      PendaftaranStatusRequestModel.fromMap(json.decode(source));
}
