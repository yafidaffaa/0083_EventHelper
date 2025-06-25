import 'package:eventhelper_fe/data/repository/auth_repository.dart';
import 'package:eventhelper_fe/pages/auth/bloc/login/login_bloc.dart';
import 'package:eventhelper_fe/pages/auth/bloc/register/register_bloc.dart';
import 'package:eventhelper_fe/pages/auth/login_page.dart';
import 'package:eventhelper_fe/service/service_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => LoginBloc(
                authRepository: AuthRepository(ServiceHttpClient()),
              ),
        ),
        BlocProvider(
          create:
              (context) => RegisterBloc(
                authRepository: AuthRepository(ServiceHttpClient()),
              ),
        ),
        // BlocProvider(
        //   create:
        //       (context) => ProfileBuyerBloc(
        //         profileBuyerRepository: ProfileBuyerRepository(
        //           ServiceHttpClient(),
        //         ),
        //       ),
        // ),
        // BlocProvider(
        //   create:
        //       (context) => GetBurungTersediaBloc(
        //         GetAllBurungTersediaRepository(ServiceHttpClient()),
        //       ),
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
