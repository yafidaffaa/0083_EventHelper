import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhelper_fe/pages/mahasiswa/bloc/profile/profile_bloc.dart';
import 'package:eventhelper_fe/pages/mahasiswa/home/mahasiswa_home_page.dart';
import 'package:intl/intl.dart';

class MahasiswaProfilePage extends StatefulWidget {
  const MahasiswaProfilePage({super.key});

  @override
  State<MahasiswaProfilePage> createState() => _MahasiswaProfilePageState();
}

class _MahasiswaProfilePageState extends State<MahasiswaProfilePage>
    with TickerProviderStateMixin {
  int _currentIndex = 1;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

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

    context.read<MahasiswaProfileBloc>().add(LoadMahasiswaProfile());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MahasiswaHomePage()),
      );
    }
  }

  void _logout() {
    context.read<MahasiswaProfileBloc>().add(LogoutMahasiswa());
  }

  void _goToEdit(dynamic profile) {
    Navigator.pushNamed(
      context,
      '/mahasiswa/profile/edit',
      arguments: profile,
    ).then((_) {
      context.read<MahasiswaProfileBloc>().add(LoadMahasiswaProfile());
    });
  }

  bool _isProfileIncomplete(dynamic profile) {
    return profile == null ||
        (profile.nama ?? '').isEmpty ||
        (profile.nim ?? '').isEmpty ||
        (profile.prodi ?? '').isEmpty ||
        (profile.angkatan ?? '').isEmpty;
  }

  // Fungsi untuk navigasi ke halaman edit dengan data kosong
  void _goToCreateProfile() {
    Navigator.pushNamed(
      context,
      '/mahasiswa/profile/edit',
      arguments: {
        'id': 0,
        'userId': 0,
        'nama': '',
        'nim': '',
        'prodi': '',
        'angkatan': '',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      },
    ).then((_) {
      // Reload profile setelah kembali dari edit
      context.read<MahasiswaProfileBloc>().add(LoadMahasiswaProfile());
    });
  }

  // Fungsi untuk mengecek apakah error menunjukkan profile kosong/tidak lengkap
  bool _isProfileEmptyError(String error) {
    final errorLower = error.toLowerCase();
    return errorLower.contains('tidak tersedia') ||
        errorLower.contains('belum tersedia') ||
        errorLower.contains('tidak ditemukan') ||
        errorLower.contains('not found') ||
        errorLower.contains('belum lengkap') ||
        errorLower.contains('kosong') ||
        errorLower.contains('empty') ||
        errorLower.contains('null');
  }

  Widget _buildProfileCard(dynamic profile) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667eea).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF667eea),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (profile?.nama?.isNotEmpty ?? false)
                                    ? profile.nama
                                    : 'Nama belum diisi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (profile?.nama?.isEmpty ?? true)
                                          ? Colors.grey[600]
                                          : const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mahasiswa',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      icon: Icons.badge,
                      label: 'Nomor Induk Mahasiswa',
                      value: profile?.nim ?? 'Belum diisi',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.school,
                      label: 'Program Studi',
                      value: profile?.prodi ?? 'Belum diisi',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.date_range,
                      label: 'Angkatan',
                      value: profile?.angkatan ?? 'Belum diisi',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Bergabung sejak',
                      value:
                          profile?.createdAt != null
                              ? DateFormat(
                                'dd MMM yyyy',
                              ).format(profile.createdAt.toLocal())
                              : 'Belum diisi',
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _goToEdit(profile),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Edit Profil',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: IconButton(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            tooltip: 'Logout',
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isEmpty = value == 'Belum diisi' || value.isEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border:
            isEmpty ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isEmpty ? Colors.orange[600] : const Color(0xFF667eea),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isEmpty ? Colors.orange[600] : const Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            SizedBox(height: 24),
            Text(
              'Memuat data profil...',
              style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PROFIL MAHASISWA',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola informasi mahasiswa Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: BlocConsumer<MahasiswaProfileBloc, MahasiswaProfileState>(
                listener: (context, state) {
                  if (state is MahasiswaLogoutSuccess) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  } else if (state is MahasiswaProfileFailure) {
                    // Cek apakah error menunjukkan profile kosong/tidak lengkap
                    if (_isProfileEmptyError(state.error)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _goToCreateProfile();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal: ${state.error}'),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else if (state is MahasiswaProfileLoaded) {
                    // Jika profile berhasil dimuat tapi datanya tidak lengkap
                    if (_isProfileIncomplete(state.profile)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _goToCreateProfile();
                      });
                    }
                  }
                },
                builder: (context, state) {
                  if (state is MahasiswaProfileLoading) {
                    return _buildLoadingState();
                  }

                  if (state is MahasiswaProfileLoaded &&
                      !_isProfileIncomplete(state.profile)) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: _buildProfileCard(state.profile),
                    );
                  }

                  // Jika state adalah failure atau profile incomplete, tampilkan loading
                  // karena akan di-redirect ke halaman edit
                  return _buildLoadingState();
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
