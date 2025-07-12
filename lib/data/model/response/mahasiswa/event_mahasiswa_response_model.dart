import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';

class EventMahasiswaResponseModel {
  final int id;
  final int? userId;
  final int? eventId;
  final String? status;
  final String? alasan;
  final EventResponseModel? event;

  EventMahasiswaResponseModel({
    required this.id,
    this.userId,
    this.eventId,
    this.status,
    this.alasan,
    this.event,
  });

  factory EventMahasiswaResponseModel.fromJson(Map<String, dynamic> json) {
    return EventMahasiswaResponseModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      eventId: json['event_id'],
      status: json['status'],
      alasan: json['alasan'],
      event:
          json['event'] != null
              ? EventResponseModel.fromJson(json['event'])
              : null,
    );
  }
}
