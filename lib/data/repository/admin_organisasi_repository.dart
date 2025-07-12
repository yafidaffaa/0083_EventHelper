import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:eventhelper_fe/data/model/request/admin/admin_organisasi_request_model.dart';
import 'package:eventhelper_fe/data/model/response/admin/admin_organisasi_response_model.dart';
import 'package:eventhelper_fe/service/service_http_client.dart';

class AdminOrganisasiRepository {
  final ServiceHttpClient _client;

  AdminOrganisasiRepository(this._client);

  // Create organisasi
  Future<Either<String, AdminOrganisasiResponseModel>> createOrganisasi(
    AdminOrganisasiRequestModel request,
  ) async {
    try {
      final response = await _client.postWithToken(
        'organisasi',
        request.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(AdminOrganisasiResponseModel.fromMap(jsonResponse));
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to create organisasi');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // Get all organisasi
  Future<Either<String, List<OrganisasiData>>> getAllOrganisasi() async {
    try {
      final response = await _client.get('organisasi');
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonResponse;
        return Right(OrganisasiData.fromList(list));
      } else {
        return Left('Failed to load organisasi');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // Get detail organisasi
  Future<Either<String, OrganisasiData>> getOrganisasiById(int id) async {
    try {
      final response = await _client.get('organisasi/$id');
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return Right(OrganisasiData.fromMap(jsonResponse));
      } else {
        return Left('Failed to load detail organisasi');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // Update organisasi
  Future<Either<String, AdminOrganisasiResponseModel>> updateOrganisasi(
    int id,
    AdminOrganisasiRequestModel request,
  ) async {
    try {
      final response = await _client.put('organisasi/$id', request.toMap());
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return Right(AdminOrganisasiResponseModel.fromMap(jsonResponse));
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to update organisasi');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // Delete organisasi
  Future<Either<String, String>> deleteOrganisasi(int id) async {
    try {
      final response = await _client.delete('organisasi/$id');
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? 'Organisasi deleted');
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to delete organisasi');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // Logout
  Future<Either<String, String>> logout() async {
    try {
      final response = await _client.postWithToken('logout', {});
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? 'Logout berhasil');
      } else {
        return Left(jsonResponse['message'] ?? 'Gagal logout');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
