import 'package:bloc/bloc.dart';
import 'package:eventhelper_fe/data/model/request/mahasiswa/event_mahasiswa_request_model.dart';
import 'package:eventhelper_fe/data/model/response/mahasiswa/event_mahasiswa_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/data/repository/event_mahasiswa_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class MahasiswaHomeBloc extends Bloc<MahasiswaHomeEvent, MahasiswaHomeState> {
  final EventMahasiswaRepository mahasiswaRepository;

  MahasiswaHomeBloc(this.mahasiswaRepository) : super(MahasiswaHomeInitial()) {
    on<LoadEventYangDiikuti>((event, emit) async {
      emit(MahasiswaHomeLoading());
      final result = await mahasiswaRepository.fetchMyRegistrations();
      result.fold(
        (e) => emit(MahasiswaHomeFailure(e)),
        (list) => emit(MahasiswaRegisteredEventListLoaded(list)),
      );
    });

    on<DaftarEvent>((event, emit) async {
      emit(MahasiswaHomeLoading());
      final result = await mahasiswaRepository.registerToEvent(event.request);
      result.fold(
        (e) => emit(MahasiswaHomeFailure(e)),
        (msg) => emit(MahasiswaEventActionSuccess(msg)),
      );
    });

    on<LoadAllEvent>((event, emit) async {
      emit(MahasiswaHomeLoading());
      final result = await mahasiswaRepository.fetchAllEvents();
      result.fold(
        (e) => emit(MahasiswaHomeFailure(e)),
        (list) => emit(MahasiswaAllEventListLoaded(list)),
      );
    });
  }
}
