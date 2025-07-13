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
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isNew = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
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

    _setupControllers();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _animationController.forward(),
    );
  }

  void _setupControllers() {
    final state = context.read<MahasiswaProfileBloc>().state;

    if (state is MahasiswaProfileLoaded) {
      final profile = state.profile;

      _isNew = _isIncomplete(profile);
      _namaController = TextEditingController(text: profile.nama ?? '');
      _nimController = TextEditingController(text: profile.nim ?? '');
      _prodiController = TextEditingController(text: profile.prodi ?? '');
      _angkatanController = TextEditingController(text: profile.angkatan ?? '');
    } else {
      _isNew = true;
      _namaController = TextEditingController();
      _nimController = TextEditingController();
      _prodiController = TextEditingController();
      _angkatanController = TextEditingController();
    }
  }

  bool _isIncomplete(dynamic p) {
    return p == null ||
        (p.nama ?? '').isEmpty ||
        (p.nim ?? '').isEmpty ||
        (p.prodi ?? '').isEmpty ||
        (p.angkatan ?? '').isEmpty;
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
      setState(() {
        _isSubmitted = true;
      });

      context.read<MahasiswaProfileBloc>().add(
        UpdateMahasiswaProfile(
          MahasiswaProfileRequestModel(
            nama: _namaController.text.trim(),
            nim: _nimController.text.trim(),
            prodi: _prodiController.text.trim(),
            angkatan: _angkatanController.text.trim(),
          ),
        ),
      );
    }
  }

  String? _validateField(String? val, {required String label, int min = 2}) {
    if (val == null || val.trim().isEmpty) return '$label tidak boleh kosong';
    if (val.trim().length < min) return '$label minimal $min karakter';
    return null;
  }

  String? _validateAngkatan(String? val) {
    if (val == null || val.trim().isEmpty) return 'Angkatan tidak boleh kosong';
    final angkatan = int.tryParse(val.trim());
    if (angkatan == null) return 'Angkatan harus berupa angka';
    final now = DateTime.now().year;
    if (angkatan < 1900 || angkatan > now + 1) return 'Angkatan tidak valid';
    return null;
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        style: const TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea), size: 20),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isNew ? Icons.info_outline : Icons.edit_note,
              color: const Color(0xFF667eea),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isNew ? 'Profil Baru' : 'Edit Profil',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isNew
                      ? 'Silakan lengkapi data mahasiswa Anda'
                      : 'Perbarui data mahasiswa Anda di bawah ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF667eea).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isNew ? Icons.person_add : Icons.edit,
                              color: const Color(0xFF667eea),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isNew ? 'Buat Profil' : 'Edit Profil',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isNew
                                      ? 'Lengkapi informasi mahasiswa Anda'
                                      : 'Perbarui informasi mahasiswa Anda',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Info Banner
                      _buildInfoBanner(),

                      // Form Fields
                      _buildCustomTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        icon: Icons.person,
                        validator: (val) => _validateField(val, label: 'Nama'),
                      ),

                      _buildCustomTextField(
                        controller: _nimController,
                        label: 'NIM',
                        icon: Icons.badge,
                        validator:
                            (val) => _validateField(val, label: 'NIM', min: 5),
                      ),

                      _buildCustomTextField(
                        controller: _prodiController,
                        label: 'Program Studi',
                        icon: Icons.school,
                        validator:
                            (val) =>
                                _validateField(val, label: 'Program Studi'),
                      ),

                      _buildCustomTextField(
                        controller: _angkatanController,
                        label: 'Angkatan',
                        icon: Icons.calendar_today,
                        inputType: TextInputType.number,
                        validator: _validateAngkatan,
                      ),

                      const SizedBox(height: 8),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitted ? null : _submit,
                            icon:
                                _isSubmitted
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Icon(
                                      _isNew ? Icons.save : Icons.update,
                                      color: Colors.white,
                                    ),
                            label: Text(
                              _isSubmitted
                                  ? 'Menyimpan...'
                                  : _isNew
                                  ? 'Buat Profil'
                                  : 'Simpan Perubahan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
            height: MediaQuery.of(context).size.height * 0.25,
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
                  // Back Button and Title
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isNew ? 'BUAT PROFIL' : 'EDIT PROFIL',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isNew
                                    ? 'Lengkapi informasi mahasiswa'
                                    : 'Perbarui informasi mahasiswa',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: BlocListener<MahasiswaProfileBloc, MahasiswaProfileState>(
                listener: (context, state) {
                  if (state is MahasiswaProfileUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Profil berhasil diperbarui'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    });
                  } else if (state is MahasiswaProfileFailure && _isSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Gagal: ${state.error}')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {
                      _isSubmitted = false;
                    });
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: _buildFormCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
