import 'package:bloc/bloc.dart';
import 'package:eventhelper_fe/data/model/request/admin/admin_organisasi_request_model.dart';
import 'package:eventhelper_fe/data/model/response/admin/admin_organisasi_response_model.dart';
import 'package:eventhelper_fe/data/repository/admin_organisasi_repository.dart';

part 'organisasi_event.dart';
part 'organisasi_state.dart';

class AdminOrganisasiBloc
    extends Bloc<AdminOrganisasiEvent, AdminOrganisasiState> {
  final AdminOrganisasiRepository repository;
  List<OrganisasiData> _allData = [];

  AdminOrganisasiBloc(this.repository) : super(AdminOrganisasiInitial()) {
    // Reset state ke initial atau ke data terakhir yang berhasil di-load
    on<ResetOrganisasiState>((event, emit) {
      if (_allData.isNotEmpty) {
        emit(AdminOrganisasiSuccess(_allData));
      } else {
        emit(AdminOrganisasiInitial());
      }
    });

    // Load semua data organisasi
    on<LoadAllOrganisasi>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.getAllOrganisasi();
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.loadData)),
        (data) {
          _allData = data;
          emit(AdminOrganisasiSuccess(data));
        },
      );
    });

    // Search organisasi (tanpa API call, menggunakan cache)
    on<SearchOrganisasi>((event, emit) {
      if (state is AdminOrganisasiSuccess || _allData.isNotEmpty) {
        if (event.query.isEmpty) {
          emit(AdminOrganisasiSuccess(_allData));
        } else {
          final filtered =
              _allData
                  .where(
                    (e) =>
                        (e.username?.toLowerCase() ?? '').contains(
                          event.query.toLowerCase(),
                        ) ||
                        (e.email?.toLowerCase() ?? '').contains(
                          event.query.toLowerCase(),
                        ),
                  )
                  .toList();
          emit(AdminOrganisasiSuccess(filtered));
        }
      }
    });

    // Create organisasi baru
    on<CreateOrganisasi>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.createOrganisasi(event.request);
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.createData)),
        (response) => emit(AdminOrganisasiActionSuccess(response.message)),
      );
    });

    // Get detail organisasi
    on<GetOrganisasiDetail>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.getOrganisasiById(event.id);
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.loadData)),
        (data) => emit(AdminOrganisasiDetailLoaded(data)),
      );
    });

    // Update organisasi
    on<UpdateOrganisasi>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.updateOrganisasi(event.id, event.request);
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.updateData)),
        (response) => emit(AdminOrganisasiActionSuccess(response.message)),
      );
    });

    // Delete organisasi
    on<DeleteOrganisasi>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.deleteOrganisasi(event.id);
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.deleteData)),
        (message) => emit(AdminOrganisasiActionSuccess(message)),
      );
    });

    // Logout
    on<LogoutOrganisasi>((event, emit) async {
      emit(AdminOrganisasiLoading());
      final result = await repository.logout();
      result.fold(
        (error) =>
            emit(AdminOrganisasiFailure(error, type: FailureType.logout)),
        (message) => emit(AdminOrganisasiLogoutSuccess(message)),
      );
    });
  }
}
