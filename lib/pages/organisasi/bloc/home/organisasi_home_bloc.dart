import 'package:bloc/bloc.dart';
import 'package:eventhelper_fe/data/model/request/organisasi/event_request_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/pendaftar_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/profile_response_model.dart';
import 'package:eventhelper_fe/data/repository/organisasi_repository.dart';

part 'organisasi_home_event.dart';
part 'organisasi_home_state.dart';

class OrganisasiHomeBloc
    extends Bloc<OrganisasiHomeEvent, OrganisasiHomeState> {
  final OrganisasiRepository repository;

  OrganisasiHomeBloc(this.repository) : super(OrganisasiHomeInitial()) {
    on<LoadOrganisasiProfile>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.getProfile();
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (profile) => emit(OrganisasiProfileLoaded(profile)),
      );
    });

    on<LogoutOrganisasi>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.logout();
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (msg) => emit(OrganisasiLogoutSuccess(msg)),
      );
    });

    on<LoadMyEvents>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.getMyEvents();
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (list) => emit(OrganisasiEventListLoaded(list)),
      );
    });

    on<CreateEvent>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.createEvent(event.request);
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (res) => emit(OrganisasiEventActionSuccess("Event berhasil dibuat")),
      );
    });

    on<GetEventDetail>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.getEventById(event.id);
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (data) => emit(OrganisasiEventDetailLoaded(data)),
      );
    });

    on<UpdateEvent>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.updateEvent(event.id, event.request);
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (msg) => emit(OrganisasiEventActionSuccess(msg)),
      );
    });

    on<DeleteEvent>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.deleteEvent(event.id);
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (msg) => emit(OrganisasiEventActionSuccess(msg)),
      );
    });

    on<LoadPendaftarByEventId>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.getPendaftarByEventId(event.eventId);
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (list) => emit(OrganisasiPendaftarLoaded(list)),
      );
    });

    on<UpdateStatusPendaftar>((event, emit) async {
      emit(OrganisasiHomeLoading());
      final result = await repository.updateStatusPendaftaran(
        event.pendaftaranId,
        event.status,
        event.alasan,
      );
      result.fold(
        (e) => emit(OrganisasiHomeFailure(e)),
        (msg) => emit(OrganisasiEventActionSuccess(msg)),
      );
    });
  }
}
