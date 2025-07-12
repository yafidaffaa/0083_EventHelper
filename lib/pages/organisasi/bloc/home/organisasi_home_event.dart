part of 'organisasi_home_bloc.dart';

sealed class OrganisasiHomeEvent {}

class LoadOrganisasiProfile extends OrganisasiHomeEvent {}

class LogoutOrganisasi extends OrganisasiHomeEvent {}

class LoadMyEvents extends OrganisasiHomeEvent {}

class CreateEvent extends OrganisasiHomeEvent {
  final EventRequestModel request;
  CreateEvent(this.request);
}

class GetEventDetail extends OrganisasiHomeEvent {
  final int id;
  GetEventDetail(this.id);
}

class UpdateEvent extends OrganisasiHomeEvent {
  final int id;
  final EventRequestModel request;
  UpdateEvent(this.id, this.request);
}

class DeleteEvent extends OrganisasiHomeEvent {
  final int id;
  DeleteEvent(this.id);
}

class LoadPendaftarByEventId extends OrganisasiHomeEvent {
  final int eventId;
  LoadPendaftarByEventId(this.eventId);
}

class UpdateStatusPendaftar extends OrganisasiHomeEvent {
  final int pendaftaranId;
  final String status;
  final String alasan;
  UpdateStatusPendaftar(this.pendaftaranId, this.status, this.alasan);
}
