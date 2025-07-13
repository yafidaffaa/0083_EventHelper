import 'package:eventhelper_fe/core/components/buttons.dart';
import 'package:eventhelper_fe/core/components/custom_text_field.dart';
import 'package:eventhelper_fe/core/components/spaces.dart';
import 'package:eventhelper_fe/core/constants/colors.dart';
import 'package:eventhelper_fe/core/extentions/build_context_ext.dart';
import 'package:eventhelper_fe/data/model/request/auth/register_request_model.dart';
import 'package:eventhelper_fe/pages/auth/bloc/register/register_bloc.dart';
import 'package:eventhelper_fe/pages/auth/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController namaController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final GlobalKey<FormState> _key;
  bool isShowPassword = false;
  bool isShowConfirmPassword = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    namaController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _key = GlobalKey<FormState>();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _key.currentState?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 6,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String validator,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? onTogglePassword,
    int animationDelay = 0,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + animationDelay),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF667eea), size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validator;
              }
              if (label == 'Konfirmasi Password' &&
                  value != passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF667eea),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(
                          showPassword!
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      // Logo/Icon Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'DAFTAR AKUN',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat akun EVENT HELPER baru',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Register Form Section
              Transform.translate(
                offset: const Offset(0, -30),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username Field
                        _buildTextField(
                          label: 'Username',
                          controller: namaController,
                          validator: 'Username tidak boleh kosong',
                          icon: Icons.person_outline,
                          animationDelay: 0,
                        ),

                        const SizedBox(height: 24),

                        // Email Field
                        _buildTextField(
                          label: 'Email',
                          controller: emailController,
                          validator: 'Email tidak boleh kosong',
                          icon: Icons.email_outlined,
                          animationDelay: 100,
                        ),

                        const SizedBox(height: 24),

                        // Password Field
                        _buildTextField(
                          label: 'Password',
                          controller: passwordController,
                          validator: 'Password tidak boleh kosong',
                          icon: Icons.lock_outline,
                          obscureText: !isShowPassword,
                          isPassword: true,
                          showPassword: isShowPassword,
                          onTogglePassword: () {
                            setState(() {
                              isShowPassword = !isShowPassword;
                            });
                          },
                          animationDelay: 200,
                        ),

                        const SizedBox(height: 24),

                        // Confirm Password Field
                        _buildTextField(
                          label: 'Konfirmasi Password',
                          controller: confirmPasswordController,
                          validator: 'Konfirmasi password tidak boleh kosong',
                          icon: Icons.lock_outline,
                          obscureText: !isShowConfirmPassword,
                          isPassword: true,
                          showPassword: isShowConfirmPassword,
                          onTogglePassword: () {
                            setState(() {
                              isShowConfirmPassword = !isShowConfirmPassword;
                            });
                          },
                          animationDelay: 300,
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        BlocConsumer<RegisterBloc, RegisterState>(
                          listener: (context, state) {
                            if (state is RegisterSuccess) {
                              // Tampilkan snackbar hijau untuk sukses
                              _showSnackbar(state.message, Colors.green);

                              // Navigasi ke halaman login setelah delay singkat
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  context.pushAndRemoveUntil(
                                    const LoginScreen(),
                                    (route) => false,
                                  );
                                },
                              );
                            } else if (state is RegisterFailure) {
                              // Tampilkan snackbar merah untuk gagal
                              _showSnackbar(state.error, Colors.red);
                              // Tetap di halaman register (tidak perlu navigasi)
                            }
                          },
                          builder: (context, state) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    state is RegisterLoading
                                        ? null
                                        : () {
                                          if (_key.currentState!.validate()) {
                                            final request =
                                                RegisterRequestModel(
                                                  username: namaController.text,
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                  passwordConfirmation:
                                                      confirmPasswordController
                                                          .text,
                                                );
                                            context.read<RegisterBloc>().add(
                                              RegisterRequested(
                                                requestModel: request,
                                              ),
                                            );
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: Colors.grey[300],
                                ),
                                child:
                                    state is RegisterLoading
                                        ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Memuat...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                        : const Text(
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Login Link
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Sudah memiliki akun? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login disini!',
                                  style: const TextStyle(
                                    color: Color(0xFF667eea),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          context.pushAndRemoveUntil(
                                            const LoginScreen(),
                                            (route) => false,
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
