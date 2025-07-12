import 'package:eventhelper_fe/data/model/request/organisasi/profile_request_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/profile_response_model.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganisasiProfileFormPage extends StatefulWidget {
  final ProfileResponseModel existingProfile;

  const OrganisasiProfileFormPage({super.key, required this.existingProfile});

  @override
  State<OrganisasiProfileFormPage> createState() =>
      _OrganisasiProfileFormPageState();
}

class _OrganisasiProfileFormPageState extends State<OrganisasiProfileFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _prodiController;
  late TextEditingController _fakultasController;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;
    _namaController = TextEditingController(text: profile.nama);
    _prodiController = TextEditingController(text: profile.prodi);
    _fakultasController = TextEditingController(text: profile.fakultas);

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
  }

  @override
  void dispose() {
    _namaController.dispose();
    _prodiController.dispose();
    _fakultasController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = ProfileRequestModel(
        nama: _namaController.text,
        prodi: _prodiController.text,
        fakultas: _fakultasController.text,
        tipe: widget.existingProfile.tipe,
      );

      setState(() {
        _isSubmitted = true;
      });

      context.read<ProfileBloc>().add(UpdateProfile(request));
    }
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
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
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF667eea),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Profil',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Perbarui informasi organisasi Anda',
                                  style: TextStyle(
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

                      // Form Fields
                      _buildCustomTextField(
                        controller: _namaController,
                        label: 'Nama Organisasi',
                        icon: Icons.business,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                      ),

                      _buildCustomTextField(
                        controller: _prodiController,
                        label: 'Program Studi',
                        icon: Icons.school,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                      ),

                      _buildCustomTextField(
                        controller: _fakultasController,
                        label: 'Fakultas',
                        icon: Icons.account_balance,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Wajib diisi'
                                    : null,
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
                                    : const Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                            label: Text(
                              _isSubmitted
                                  ? 'Menyimpan...'
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EDIT PROFIL',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Perbarui informasi organisasi',
                                style: TextStyle(
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
              child: BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileUpdateSuccess) {
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
                      if (mounted) Navigator.pop(context);
                    });
                  } else if (state is ProfileFailure && _isSubmitted) {
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
