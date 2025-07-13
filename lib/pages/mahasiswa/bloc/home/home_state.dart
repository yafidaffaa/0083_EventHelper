part of 'home_bloc.dart';

sealed class MahasiswaHomeState {}

class MahasiswaHomeInitial extends MahasiswaHomeState {}

class MahasiswaHomeLoading extends MahasiswaHomeState {}

class MahasiswaProfileHomeLoaded extends MahasiswaHomeState {
  final MahasiswaProfileResponseModel profile;
  MahasiswaProfileHomeLoaded(this.profile);
}

class MahasiswaAllEventListLoaded extends MahasiswaHomeState {
  final List<EventData> eventList;
  MahasiswaAllEventListLoaded(this.eventList);
}

class MahasiswaRegisteredEventListLoaded extends MahasiswaHomeState {
  final List<EventMahasiswaResponseModel> eventList;
  MahasiswaRegisteredEventListLoaded(this.eventList);
}

class MahasiswaEventActionSuccess extends MahasiswaHomeState {
  final String message;
  MahasiswaEventActionSuccess(this.message);
}

class MahasiswaHomeFailure extends MahasiswaHomeState {
  final String error;
  MahasiswaHomeFailure(this.error);
}
