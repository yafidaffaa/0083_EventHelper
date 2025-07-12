part of 'organisasi_home_bloc.dart';

sealed class OrganisasiHomeState {}

class OrganisasiHomeInitial extends OrganisasiHomeState {}

class OrganisasiHomeLoading extends OrganisasiHomeState {}

class OrganisasiProfileLoaded extends OrganisasiHomeState {
  final ProfileResponseModel profile;
  OrganisasiProfileLoaded(this.profile);
}

class OrganisasiLogoutSuccess extends OrganisasiHomeState {
  final String message;
  OrganisasiLogoutSuccess(this.message);
}

class OrganisasiEventListLoaded extends OrganisasiHomeState {
  final List<EventData> events;
  OrganisasiEventListLoaded(this.events);
}

class OrganisasiEventDetailLoaded extends OrganisasiHomeState {
  final EventData detail;
  OrganisasiEventDetailLoaded(this.detail);
}

class OrganisasiEventActionSuccess extends OrganisasiHomeState {
  final String message;
  OrganisasiEventActionSuccess(this.message);
}

class OrganisasiPendaftarLoaded extends OrganisasiHomeState {
  final List<PendaftarData> pendaftar;
  OrganisasiPendaftarLoaded(this.pendaftar);
}

class OrganisasiHomeFailure extends OrganisasiHomeState {
  final String error;
  OrganisasiHomeFailure(this.error);
}
