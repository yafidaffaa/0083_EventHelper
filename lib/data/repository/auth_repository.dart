import 'dart:convert';
import 'dart:developer';

import 'package:eventhelper_fe/data/model/request/auth/login_request_model.dart';
import 'package:eventhelper_fe/data/model/request/auth/register_request_model.dart';
import 'package:eventhelper_fe/data/model/response/auth/login_response_model.dart';
import 'package:eventhelper_fe/service/service_http_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final secureStorage = FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  Future<Either<String, LoginResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        "login",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      log(response.body);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponseModel.fromMap(jsonResponse);

        // Simpan token dan role jika tersedia
        if (loginResponse.token != null) {
          await secureStorage.write(
            key: 'authToken',
            value: loginResponse.token!,
          );
        }

        if (loginResponse.user?.roleId != null) {
          await secureStorage.write(
            key: 'userRole',
            value: loginResponse.user!.roleId.toString(),
          );
        }

        return Right(loginResponse);
      } else {
        return Left(jsonResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      log('Login error: $e');
      return Left('An error occurred while logging in: $e');
    }
  }

  Future<Either<String, String>> register(
    RegisterRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        "register",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);
      final registerResponse = jsonResponse['message'];
      if (response.statusCode == 201) {
        return Right(registerResponse ?? 'Registration successful');
      } else {
        return Left(jsonResponse['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return Left('An error occurred while registering: $e');
    }
  }
}
