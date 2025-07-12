import 'package:eventhelper_fe/data/repository/admin_organisasi_repository.dart';
import 'package:eventhelper_fe/data/repository/auth_repository.dart';
import 'package:eventhelper_fe/data/repository/event_mahasiswa_repository.dart';
import 'package:eventhelper_fe/data/repository/organisasi_repository.dart';
import 'package:eventhelper_fe/pages/admin/admin_organisasi_home_page.dart';
import 'package:eventhelper_fe/pages/admin/bloc/home/organisasi_bloc.dart';
import 'package:eventhelper_fe/pages/auth/bloc/login/login_bloc.dart';
import 'package:eventhelper_fe/pages/auth/bloc/register/register_bloc.dart';
import 'package:eventhelper_fe/pages/auth/login_page.dart';
import 'package:eventhelper_fe/pages/auth/register_page.dart';
import 'package:eventhelper_fe/pages/mahasiswa/bloc/home/home_bloc.dart';
import 'package:eventhelper_fe/pages/mahasiswa/bloc/profile/profile_bloc.dart';
import 'package:eventhelper_fe/pages/mahasiswa/profile/edit_mahasiswa_profile_page.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/home/organisasi_home_bloc.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/profile/profile_bloc.dart';
import 'package:eventhelper_fe/pages/organisasi/home/organisasi_home_page.dart';
import 'package:eventhelper_fe/service/service_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = ServiceHttpClient();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginBloc(authRepository: AuthRepository(httpClient)),
        ),
        BlocProvider(
          create:
              (_) => RegisterBloc(authRepository: AuthRepository(httpClient)),
        ),
        BlocProvider(
          create:
              (_) => AdminOrganisasiBloc(AdminOrganisasiRepository(httpClient)),
        ),
        BlocProvider(
          create: (_) => OrganisasiHomeBloc(OrganisasiRepository(httpClient)),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(OrganisasiRepository(httpClient)),
        ),
        BlocProvider(
          create:
              (_) => MahasiswaHomeBloc(EventMahasiswaRepository(httpClient)),
        ),
        BlocProvider(
          create:
              (_) => MahasiswaProfileBloc(EventMahasiswaRepository(httpClient)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EventHelper',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/organisasi': (context) => const AdminOrganisasiHomePage(),
          '/events': (context) => const OrganisasiHomePage(),
          '/mahasiswa/profile/edit':
              (context) => const EditMahasiswaProfilePage(),
        },
      ),
    );
  }
}
