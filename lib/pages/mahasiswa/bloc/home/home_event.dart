part of 'home_bloc.dart';

sealed class MahasiswaHomeEvent {}

class LoadMahasiswaProfileHome extends MahasiswaHomeEvent {}

class LoadAllEvent extends MahasiswaHomeEvent {}

class LoadEventYangDiikuti extends MahasiswaHomeEvent {}

class DaftarEvent extends MahasiswaHomeEvent {
  final EventMahasiswaRequestModel request;
  DaftarEvent(this.request);
}
