import 'dart:convert';

class PendaftaranStatusResponseModel {
  final String message;

  PendaftaranStatusResponseModel({required this.message});

  factory PendaftaranStatusResponseModel.fromMap(Map<String, dynamic> map) {
    return PendaftaranStatusResponseModel(message: map['message'] ?? '');
  }

  factory PendaftaranStatusResponseModel.fromJson(String source) =>
      PendaftaranStatusResponseModel.fromMap(json.decode(source));
}
