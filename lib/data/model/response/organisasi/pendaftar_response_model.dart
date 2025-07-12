class PendaftarData {
  final int id;
  final String nama;
  final String nim;
  final String status;
  final String alasan;
  final int userId;
  final int eventId;
  final String? prodi;
  final String? fakultas;

  PendaftarData({
    required this.id,
    required this.nama,
    required this.nim,
    required this.status,
    required this.alasan,
    required this.userId,
    required this.eventId,
    this.prodi,
    this.fakultas,
  });

  factory PendaftarData.fromMap(Map<String, dynamic> map) {
    return PendaftarData(
      id: map['id'],
      nama: map['nama'] ?? '',
      nim: map['nim'] ?? '',
      status: map['status'] ?? 'pending',
      alasan: map['alasan'] ?? '',
      userId: map['user_id'],
      eventId: map['event_id'],
      prodi: map['prodi'],
      fakultas: map['fakultas'],
    );
  }

  static List<PendaftarData> fromList(List<dynamic> list) {
    return list.map((e) => PendaftarData.fromMap(e)).toList();
  }
}
