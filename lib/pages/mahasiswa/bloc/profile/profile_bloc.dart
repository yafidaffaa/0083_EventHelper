import 'package:bloc/bloc.dart';
import 'package:eventhelper_fe/data/model/request/mahasiswa/profile_request_model.dart';
import 'package:eventhelper_fe/data/model/response/mahasiswa/profile_response_model.dart';
import 'package:eventhelper_fe/data/repository/event_mahasiswa_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class MahasiswaProfileBloc
    extends Bloc<MahasiswaProfileEvent, MahasiswaProfileState> {
  final EventMahasiswaRepository mahasiswaRepository;

  MahasiswaProfileBloc(this.mahasiswaRepository)
    : super(MahasiswaProfileInitial()) {
    on<LoadMahasiswaProfile>((event, emit) async {
      emit(MahasiswaProfileLoading());
      final result = await mahasiswaRepository.getProfile();
      result.fold(
        (e) => emit(MahasiswaProfileFailure(e)),
        (profile) => emit(MahasiswaProfileLoaded(profile)),
      );
    });

    on<UpdateMahasiswaProfile>((event, emit) async {
      emit(MahasiswaProfileLoading());
      final result = await mahasiswaRepository.updateProfile(event.request);
      result.fold(
        (e) => emit(MahasiswaProfileFailure(e)),
        (msg) => emit(MahasiswaProfileUpdated(msg)),
      );
    });

    on<LogoutMahasiswa>((event, emit) async {
      emit(MahasiswaProfileLoading());
      final result = await mahasiswaRepository.logout();
      result.fold(
        (e) => emit(MahasiswaProfileFailure(e)),
        (msg) => emit(MahasiswaLogoutSuccess(msg)),
      );
    });
  }
}
