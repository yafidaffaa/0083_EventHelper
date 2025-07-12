import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:eventhelper_fe/data/model/request/mahasiswa/event_mahasiswa_request_model.dart';
import 'package:eventhelper_fe/data/model/request/mahasiswa/profile_request_model.dart';
import 'package:eventhelper_fe/data/model/response/mahasiswa/event_mahasiswa_response_model.dart';
import 'package:eventhelper_fe/data/model/response/mahasiswa/profile_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart'; // Import model yang sudah ada
import 'package:eventhelper_fe/service/service_http_client.dart';

class EventMahasiswaRepository {
  final ServiceHttpClient _http;

  EventMahasiswaRepository(this._http);

  /// Mahasiswa melihat event yang dia daftar
  Future<Either<String, List<EventMahasiswaResponseModel>>>
  fetchMyRegistrations() async {
    try {
      final response = await _http.getWithToken('event-mahasiswa');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final result =
            data.map((e) => EventMahasiswaResponseModel.fromJson(e)).toList();
        return Right(result);
      } else {
        final body = json.decode(response.body);
        return Left(body['message'] ?? 'Gagal mengambil pendaftaran');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// Mahasiswa mendaftar ke event
  Future<Either<String, String>> registerToEvent(
    EventMahasiswaRequestModel request,
  ) async {
    try {
      final response = await _http.postWithToken(
        'event-mahasiswa',
        request.toJson(),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return Right("Berhasil mendaftar event");
      } else {
        return Left(body['message'] ?? 'Gagal mendaftar event');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// GET /profile - Ambil profil mahasiswa
  Future<Either<String, MahasiswaProfileResponseModel>> getProfile() async {
    try {
      final response = await _http.get('profile');
      if (response.body.isEmpty) return Left('Data profil kosong');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['id'] == null || data['user_id'] == null) {
          return Left('Profil belum lengkap');
        }
        return Right(MahasiswaProfileResponseModel.fromMap(data));
      } else {
        return Left(data['message'] ?? 'Gagal mengambil profil');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// PUT /profile - Update profil mahasiswa
  Future<Either<String, String>> updateProfile(
    MahasiswaProfileRequestModel request,
  ) async {
    try {
      final response = await _http.putWithToken('profile', request.toMap());
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Profil berhasil diperbarui');
      } else {
        return Left(data['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// POST /logout - Logout mahasiswa
  Future<Either<String, String>> logout() async {
    try {
      final response = await _http.postWithToken('logout', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Right(data['message'] ?? 'Berhasil logout');
      } else {
        return Left(data['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// Menggunakan EventData untuk list events
  Future<Either<String, List<EventData>>> fetchAllEvents() async {
    try {
      final response = await _http.getWithToken('getAllEvents');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final result = EventData.fromList(data);
        return Right(result);
      } else {
        final body = json.decode(response.body);
        return Left(body['message'] ?? 'Gagal mengambil daftar event');
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }
}
