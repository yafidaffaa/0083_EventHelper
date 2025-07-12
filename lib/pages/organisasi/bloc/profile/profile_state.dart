part of 'profile_bloc.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileResponseModel profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

class ProfileLogoutSuccess extends ProfileState {
  final String message;
  ProfileLogoutSuccess(this.message);
}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
}
