import 'package:bloc/bloc.dart';
import 'package:eventhelper_fe/data/model/request/organisasi/profile_request_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/profile_response_model.dart';
import 'package:eventhelper_fe/data/repository/organisasi_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final OrganisasiRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<GetProfile>((event, emit) async {
      emit(ProfileLoading());
      final result = await repository.getProfile();
      result.fold(
        (error) => emit(ProfileFailure(error)),
        (data) => emit(ProfileLoaded(data)),
      );
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      final result = await repository.updateProfile(event.request);
      result.fold(
        (error) => emit(ProfileFailure(error)),
        (message) => emit(ProfileUpdateSuccess(message)),
      );
    });

    on<LogoutProfile>((event, emit) async {
      emit(ProfileLoading());
      final result = await repository.logout();
      result.fold(
        (error) => emit(ProfileFailure(error)),
        (message) => emit(ProfileLogoutSuccess(message)),
      );
    });
  }
}
