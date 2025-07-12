part of 'profile_bloc.dart';

sealed class ProfileEvent {}

class GetProfile extends ProfileEvent {}

class LogoutProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileRequestModel request;
  UpdateProfile(this.request);
}
