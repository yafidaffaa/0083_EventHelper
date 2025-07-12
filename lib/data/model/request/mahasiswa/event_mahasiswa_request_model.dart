class EventMahasiswaRequestModel {
  final int eventId;
  final String? alasan;

  EventMahasiswaRequestModel({required this.eventId, this.alasan});

  Map<String, dynamic> toJson() {
    return {'event_id': eventId, if (alasan != null) 'alasan': alasan};
  }
}
