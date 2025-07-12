import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:eventhelper_fe/data/model/request/organisasi/event_request_model.dart';
import 'package:eventhelper_fe/data/model/request/organisasi/profile_request_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/pendaftar_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/profile_response_model.dart';
import 'package:eventhelper_fe/service/service_http_client.dart';

class OrganisasiRepository {
  final ServiceHttpClient _client;

  OrganisasiRepository(this._client);

  // GET /me
  // Future<Either<String, ProfileResponseModel>> getProfile() async {
  //   try {
  //     final response = await _client.get('profile');
  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       return Right(ProfileResponseModel.fromMap(data));
  //     } else {
  //       return Left(data['message'] ?? 'Gagal mengambil profil');
  //     }
  //   } catch (e) {
  //     return Left(e.toString());
  //   }
  // }

  Future<Either<String, ProfileResponseModel>> getProfile() async {
    try {
      final response = await _client.get('profile');

      // Cek dulu response body kosong atau tidak
      if (response.body.isEmpty) {
        return Left('Data profil kosong');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Cek apakah map memiliki semua key penting
        if (data == null || data['id'] == null || data['user_id'] == null) {
          return Left('Profil belum tersedia');
        }

        return Right(ProfileResponseModel.fromMap(data));
      } else {
        return Left(data['message'] ?? 'Gagal mengambil profil');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  // POST /logout
  Future<Either<String, String>> logout() async {
    try {
      final response = await _client.postWithToken('logout', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Berhasil logout');
      } else {
        return Left(data['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // GET /event
  Future<Either<String, List<EventData>>> getMyEvents() async {
    try {
      final response = await _client.getWithToken('events');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(EventData.fromList(data));
      } else {
        return Left(data['message'] ?? 'Gagal memuat event');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // POST /event
  Future<Either<String, EventResponseModel>> createEvent(
    EventRequestModel request,
  ) async {
    try {
      final response = await _client.postWithToken('events', request.toMap());
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(EventResponseModel.fromMap(data));
      } else {
        return Left(data['message'] ?? 'Gagal menambahkan event');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // GET /event/{id}
  Future<Either<String, EventData>> getEventById(int id) async {
    try {
      final response = await _client.getWithToken('events/$id');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(EventData.fromMap(data));
      } else {
        return Left(data['message'] ?? 'Gagal memuat detail event');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // PUT /event/{id}
  Future<Either<String, String>> updateEvent(
    int id,
    EventRequestModel request,
  ) async {
    try {
      final response = await _client.putWithToken(
        'events/$id',
        request.toMap(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Event berhasil diupdate');
      } else {
        return Left(data['message'] ?? 'Gagal mengupdate event');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // DELETE /event/{id}
  Future<Either<String, String>> deleteEvent(int id) async {
    try {
      final response = await _client.deleteWithToken('events/$id');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Event berhasil dihapus');
      } else {
        return Left(data['message'] ?? 'Gagal menghapus event');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // GET /event/{id}/pendaftar
  Future<Either<String, List<PendaftarData>>> getPendaftarByEventId(
    int eventId,
  ) async {
    try {
      final response = await _client.getWithToken('event/$eventId/pendaftar');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(PendaftarData.fromList(data));
      } else {
        return Left(data['message'] ?? 'Gagal memuat pendaftar');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  // PUT /pendaftaran/{id} → untuk menyetujui/menolak pendaftar
  Future<Either<String, String>> updateStatusPendaftaran(
    int pendaftaranId,
    String status,
    String alasan,
  ) async {
    try {
      final body = {'status': status, 'alasan': alasan};
      final response = await _client.putWithToken(
        'event-mahasiswa/$pendaftaranId/review',
        body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Status diperbarui');
      } else {
        return Left(data['message'] ?? 'Gagal memperbarui status');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> updateProfile(
    ProfileRequestModel request,
  ) async {
    try {
      final response = await _client.putWithToken('profile', request.toMap());
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Profil berhasil diperbarui');
      } else {
        return Left(data['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
