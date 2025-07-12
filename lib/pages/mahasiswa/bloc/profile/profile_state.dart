part of 'profile_bloc.dart';

sealed class MahasiswaProfileState {}

class MahasiswaProfileInitial extends MahasiswaProfileState {}

class MahasiswaProfileLoading extends MahasiswaProfileState {}

class MahasiswaProfileLoaded extends MahasiswaProfileState {
  final MahasiswaProfileResponseModel profile;
  MahasiswaProfileLoaded(this.profile);
}

class MahasiswaProfileUpdated extends MahasiswaProfileState {
  final String message;
  MahasiswaProfileUpdated(this.message);
}

class MahasiswaLogoutSuccess extends MahasiswaProfileState {
  final String message;
  MahasiswaLogoutSuccess(this.message);
}

class MahasiswaProfileFailure extends MahasiswaProfileState {
  final String error;
  MahasiswaProfileFailure(this.error);
}
