part of 'organisasi_bloc.dart';

sealed class AdminOrganisasiEvent {}

class LoadAllOrganisasi extends AdminOrganisasiEvent {}

class SearchOrganisasi extends AdminOrganisasiEvent {
  final String query;
  SearchOrganisasi(this.query);
}

class CreateOrganisasi extends AdminOrganisasiEvent {
  final AdminOrganisasiRequestModel request;
  CreateOrganisasi(this.request);
}

class GetOrganisasiDetail extends AdminOrganisasiEvent {
  final int id;
  GetOrganisasiDetail(this.id);
}

class UpdateOrganisasi extends AdminOrganisasiEvent {
  final int id;
  final AdminOrganisasiRequestModel request;
  UpdateOrganisasi(this.id, this.request);
}

class DeleteOrganisasi extends AdminOrganisasiEvent {
  final int id;
  DeleteOrganisasi(this.id);
}

class LogoutOrganisasi extends AdminOrganisasiEvent {}

class ResetOrganisasiState extends AdminOrganisasiEvent {}
