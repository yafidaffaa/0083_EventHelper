import 'package:eventhelper_fe/data/model/request/mahasiswa/profile_request_model.dart';
import 'package:eventhelper_fe/pages/mahasiswa/bloc/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditMahasiswaProfilePage extends StatefulWidget {
  const EditMahasiswaProfilePage({super.key});

  @override
  State<EditMahasiswaProfilePage> createState() =>
      _EditMahasiswaProfilePageState();
}

class _EditMahasiswaProfilePageState extends State<EditMahasiswaProfilePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nimController;
  late TextEditingController _prodiController;
  late TextEditingController _angkatanController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    final state = context.read<MahasiswaProfileBloc>().state;

    if (state is MahasiswaProfileLoaded) {
      _namaController = TextEditingController(text: state.profile.nama);
      _nimController = TextEditingController(text: state.profile.nim);
      _prodiController = TextEditingController(text: state.profile.prodi);
      _angkatanController = TextEditingController(text: state.profile.angkatan);
    } else {
      _namaController = TextEditingController();
      _nimController = TextEditingController();
      _prodiController = TextEditingController();
      _angkatanController = TextEditingController();
    }

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _angkatanController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = MahasiswaProfileRequestModel(
        nama: _namaController.text.trim(),
        nim: _nimController.text.trim(),
        prodi: _prodiController.text.trim(),
        angkatan: _angkatanController.text.trim(),
      );

      context.read<MahasiswaProfileBloc>().add(UpdateMahasiswaProfile(request));
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + animationDelay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
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
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section with Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
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
                  const SizedBox(height: 60),
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Edit Icon Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UBAH PROFIL',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbarui informasi mahasiswa Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Section
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: BlocListener<
                  MahasiswaProfileBloc,
                  MahasiswaProfileState
                >(
                  listener: (context, state) {
                    if (state is MahasiswaProfileUpdated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    } else if (state is MahasiswaProfileFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Form Title
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Informasi Mahasiswa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Lengkapi data diri Anda dengan benar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form Fields
                          _buildFormField(
                            controller: _namaController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap Anda',
                            icon: Icons.person,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Nama tidak boleh kosong'
                                        : null,
                            animationDelay: 0,
                          ),

                          _buildFormField(
                            controller: _nimController,
                            label: 'Nomor Induk Mahasiswa',
                            hint: 'Masukkan NIM Anda',
                            icon: Icons.badge,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'NIM tidak boleh kosong'
                                        : null,
                            animationDelay: 100,
                          ),

                          _buildFormField(
                            controller: _prodiController,
                            label: 'Program Studi',
                            hint: 'Masukkan program studi Anda',
                            icon: Icons.school,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Prodi tidak boleh kosong'
                                        : null,
                            animationDelay: 200,
                          ),

                          _buildFormField(
                            controller: _angkatanController,
                            label: 'Angkatan',
                            hint: 'Masukkan tahun angkatan Anda',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Angkatan tidak boleh kosong'
                                        : null,
                            animationDelay: 300,
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: BlocBuilder<
                                    MahasiswaProfileBloc,
                                    MahasiswaProfileState
                                  >(
                                    builder: (context, state) {
                                      final isLoading =
                                          state is MahasiswaProfileLoading;

                                      return Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF667eea),
                                              Color(0xFF764ba2),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF667eea,
                                              ).withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child:
                                              isLoading
                                                  ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                  : const Text(
                                                    'Simpan Perubahan',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
