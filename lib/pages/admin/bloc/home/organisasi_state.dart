part of 'organisasi_bloc.dart';

sealed class AdminOrganisasiState {}

class AdminOrganisasiInitial extends AdminOrganisasiState {}

class AdminOrganisasiLoading extends AdminOrganisasiState {}

class AdminOrganisasiSuccess extends AdminOrganisasiState {
  final List<OrganisasiData> data;
  AdminOrganisasiSuccess(this.data);
}

class AdminOrganisasiDetailLoaded extends AdminOrganisasiState {
  final OrganisasiData detail;
  AdminOrganisasiDetailLoaded(this.detail);
}

class AdminOrganisasiActionSuccess extends AdminOrganisasiState {
  final String message;
  AdminOrganisasiActionSuccess(this.message);
}

class AdminOrganisasiFailure extends AdminOrganisasiState {
  final String error;
  final FailureType type;

  AdminOrganisasiFailure(this.error, {required this.type});
}

class AdminOrganisasiLogoutSuccess extends AdminOrganisasiState {
  final String message;
  AdminOrganisasiLogoutSuccess(this.message);
}

// Enum untuk membedakan jenis failure
enum FailureType { loadData, createData, updateData, deleteData, logout }
