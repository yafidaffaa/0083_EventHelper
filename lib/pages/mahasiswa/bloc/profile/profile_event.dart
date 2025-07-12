part of 'profile_bloc.dart';

sealed class MahasiswaProfileEvent {}

class LoadMahasiswaProfile extends MahasiswaProfileEvent {}

class UpdateMahasiswaProfile extends MahasiswaProfileEvent {
  final MahasiswaProfileRequestModel request;
  UpdateMahasiswaProfile(this.request);
}

class LogoutMahasiswa extends MahasiswaProfileEvent {}
