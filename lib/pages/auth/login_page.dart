// // import 'package:canary/data/model/request/auth/login_request_model.dart';
// // import 'package:canary/presentation/admin/admin_confirm_screen.dart';
// // import 'package:canary/presentation/auth/bloc/login/login_bloc.dart';
// // import 'package:canary/presentation/auth/register_screen.dart';
// // import 'package:canary/presentation/buyer/profile/buyer_profile_screen.dart';
// import 'package:eventhelper_fe/core/components/buttons.dart';
// import 'package:eventhelper_fe/core/components/custom_text_field.dart';
// import 'package:eventhelper_fe/core/components/spaces.dart';
// import 'package:eventhelper_fe/core/constants/colors.dart';
// import 'package:eventhelper_fe/core/extentions/build_context_ext.dart';
// import 'package:eventhelper_fe/data/model/request/auth/login_request_model.dart';
// import 'package:eventhelper_fe/pages/admin/home/admin_home_page.dart';
// import 'package:eventhelper_fe/pages/auth/bloc/login/login_bloc.dart';
// import 'package:eventhelper_fe/pages/auth/register_page.dart';
// import 'package:eventhelper_fe/pages/mahasiswa/home/mahasiswa_home_page.dart';
// import 'package:eventhelper_fe/pages/organisasi/home/organisasi_home_page.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   late final TextEditingController emailController;
//   late final TextEditingController passwordController;
//   late final GlobalKey<FormState> _key;
//   bool isShowPassword = false;

//   @override
//   void initState() {
//     emailController = TextEditingController();
//     passwordController = TextEditingController();
//     _key = GlobalKey<FormState>();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     _key.currentState?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Form(
//           key: _key,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SpaceHeight(170),
//                 Text(
//                   'SELAMAT DATANG KEMBALI',
//                   style: TextStyle(
//                     fontSize: MediaQuery.of(context).size.width * 0.05,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SpaceHeight(30),
//                 CustomTextField(
//                   validator: 'Email tidak boleh kosong',
//                   controller: emailController,
//                   label: 'Email',
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Icon(Icons.email),
//                   ),
//                 ),
//                 const SpaceHeight(25),
//                 CustomTextField(
//                   validator: 'Password tidak boleh kosong',
//                   controller: passwordController,
//                   label: 'Password',
//                   obscureText: isShowPassword,
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Icon(Icons.lock),
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         isShowPassword = !isShowPassword;
//                       });
//                     },
//                     icon: Icon(
//                       isShowPassword ? Icons.visibility : Icons.visibility_off,
//                       color: AppColors.grey,
//                     ),
//                   ),
//                 ),
//                 const SpaceHeight(30),
//                 BlocConsumer<LoginBloc, LoginState>(
//                   listener: (context, state) {
//                     if (state is LoginFailure) {
//                       ScaffoldMessenger.of(
//                         context,
//                       ).showSnackBar(SnackBar(content: Text(state.error)));
//                     } else if (state is LoginSuccess) {
//                       final role =
//                           state.responseModel.user?.role?.toLowerCase();
//                       if (role == 'admin') {
//                         context.pushAndRemoveUntil(
//                           const AdminHomeScreen(),
//                           (route) => false,
//                         );
//                       } else if (role == 'mhs') {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(state.responseModel.message!)),
//                         );
//                         context.pushAndRemoveUntil(
//                           const MahasiswaHomePage(),
//                           (route) => false,
//                         );
//                       } else if (role == 'organisasi') {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(state.responseModel.message!)),
//                         );
//                         context.pushAndRemoveUntil(
//                           const OrganisasiHomePage(),
//                           (route) => false,
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Role tidak dikenali')),
//                         );
//                       }
//                     }
//                   },
//                   builder: (context, state) {
//                     return Button.filled(
//                       onPressed:
//                           state is LoginLoading
//                               ? null
//                               : () {
//                                 if (_key.currentState!.validate()) {
//                                   final request = LoginRequestModel(
//                                     email: emailController.text,
//                                     password: passwordController.text,
//                                   );
//                                   context.read<LoginBloc>().add(
//                                     LoginRequested(requestModel: request),
//                                   );
//                                 }
//                               },
//                       label: state is LoginLoading ? 'Memuat...' : 'Masuk',
//                     );
//                   },
//                 ),
//                 const SpaceHeight(20),
//                 Text.rich(
//                   TextSpan(
//                     text: 'Belum memiliki akun? Silahkan ',
//                     style: TextStyle(
//                       color: AppColors.grey,
//                       fontSize: MediaQuery.of(context).size.width * 0.03,
//                     ),
//                     children: [
//                       TextSpan(
//                         text: 'daftar disini!',
//                         style: TextStyle(color: AppColors.primary),
//                         recognizer:
//                             TapGestureRecognizer()
//                               ..onTap = () {
//                                 context.push(const RegisterScreen());
//                               },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:eventhelper_fe/core/components/buttons.dart';
import 'package:eventhelper_fe/core/components/custom_text_field.dart';
import 'package:eventhelper_fe/core/components/spaces.dart';
import 'package:eventhelper_fe/core/constants/colors.dart';
import 'package:eventhelper_fe/core/extentions/build_context_ext.dart';
import 'package:eventhelper_fe/data/model/request/auth/login_request_model.dart';
import 'package:eventhelper_fe/pages/admin/home/admin_home_page.dart';
import 'package:eventhelper_fe/pages/auth/bloc/login/login_bloc.dart';
import 'package:eventhelper_fe/pages/auth/register_page.dart';
import 'package:eventhelper_fe/pages/mahasiswa/home/mahasiswa_home_page.dart';
import 'package:eventhelper_fe/pages/organisasi/home/organisasi_home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String getRoleFromId(int? roleId) {
  switch (roleId) {
    case 1:
      return 'admin';
    case 2:
      return 'mhs';
    case 3:
      return 'organisasi';
    default:
      return 'unknown';
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> _key;
  bool isShowPassword = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _key = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _key.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpaceHeight(170),
                Text(
                  'SELAMAT DATANG KEMBALI',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SpaceHeight(30),
                CustomTextField(
                  validator: 'Email tidak boleh kosong',
                  controller: emailController,
                  label: 'Email',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.email),
                  ),
                ),
                const SpaceHeight(25),
                CustomTextField(
                  validator: 'Password tidak boleh kosong',
                  controller: passwordController,
                  label: 'Password',
                  obscureText: isShowPassword,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.lock),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isShowPassword = !isShowPassword;
                      });
                    },
                    icon: Icon(
                      isShowPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SpaceHeight(30),
                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    } else if (state is LoginSuccess) {
                      final role =
                          getRoleFromId(
                            state.responseModel.user?.roleId,
                          ).toLowerCase();

                      if (role == 'admin') {
                        context.pushAndRemoveUntil(
                          const AdminHomeScreen(),
                          (route) => false,
                        );
                      } else if (role == 'mhs') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.responseModel.message!)),
                        );
                        context.pushAndRemoveUntil(
                          const MahasiswaHomePage(),
                          (route) => false,
                        );
                      } else if (role == 'organisasi') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.responseModel.message!)),
                        );
                        context.pushAndRemoveUntil(
                          const OrganisasiHomePage(),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Role tidak dikenali')),
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return Button.filled(
                      onPressed:
                          state is LoginLoading
                              ? null
                              : () {
                                if (_key.currentState!.validate()) {
                                  final request = LoginRequestModel(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  context.read<LoginBloc>().add(
                                    LoginRequested(requestModel: request),
                                  );
                                }
                              },
                      label: state is LoginLoading ? 'Memuat...' : 'Masuk',
                    );
                  },
                ),
                const SpaceHeight(20),
                Text.rich(
                  TextSpan(
                    text: 'Belum memiliki akun? Silahkan ',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                    ),
                    children: [
                      TextSpan(
                        text: 'daftar disini!',
                        style: TextStyle(color: AppColors.primary),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                context.push(const RegisterScreen());
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
