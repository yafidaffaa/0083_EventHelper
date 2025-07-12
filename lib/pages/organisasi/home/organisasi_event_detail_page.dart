import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/pendaftar_response_model.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/home/organisasi_home_bloc.dart';
import 'package:eventhelper_fe/pages/organisasi/home/organisasi_event_form_page.dart';
import 'package:eventhelper_fe/pages/organisasi/home/pendaftaran_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganisasiEventDetailPage extends StatefulWidget {
  final int eventId;
  const OrganisasiEventDetailPage({super.key, required this.eventId});

  @override
  State<OrganisasiEventDetailPage> createState() =>
      _OrganisasiEventDetailPageState();
}

class _OrganisasiEventDetailPageState extends State<OrganisasiEventDetailPage> {
  bool _isLoading = false;
  EventData? _cachedEventDetail;

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  void _loadEventDetail() {
    if (!_isLoading) {
      setState(() => _isLoading = true);
      context.read<OrganisasiHomeBloc>().add(GetEventDetail(widget.eventId));
    }
  }

  void _goToEdit(EventData event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganisasiEventFormPage(event: event),
      ),
    );

    // Refresh detail setelah edit jika berhasil
    if (result == true && mounted) {
      _loadEventDetail();
    }
  }

  void _confirmDelete(int eventId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Hapus Event'),
              ],
            ),
            content: const Text(
              'Yakin ingin menghapus event ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<OrganisasiHomeBloc>().add(DeleteEvent(eventId));
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _goToListPendaftar() async {
    // Load pendaftar data
    context.read<OrganisasiHomeBloc>().add(
      LoadPendaftarByEventId(widget.eventId),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color? foregroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildImageSection(String? photoBase64) {
    if (photoBase64 == null || photoBase64.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    try {
      // Debug: Print informasi base64
      print('Base64 length: ${photoBase64.length}');
      print(
        'Base64 starts with: ${photoBase64.substring(0, math.min(50, photoBase64.length))}',
      );

      // Cek apakah ada prefix data URL
      String cleanBase64 = photoBase64;
      if (photoBase64.contains(',')) {
        cleanBase64 = photoBase64.split(',').last;
        print('Cleaned base64 after removing prefix');
      }

      // Validasi base64
      if (!_isValidBase64(cleanBase64)) {
        print('Invalid base64 format detected');
        return _buildErrorContainer('Format base64 tidak valid');
      }

      final Uint8List imageBytes = base64Decode(cleanBase64);
      print('Successfully decoded base64 to ${imageBytes.length} bytes');

      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image.memory error: $error');
              return _buildErrorContainer('Gagal memuat gambar');
            },
          ),
        ),
      );
    } catch (e) {
      print('Exception in _buildImageSection: $e');
      return _buildErrorContainer('Format gambar tidak valid: ${e.toString()}');
    }
  }

  // Helper method untuk validasi base64
  bool _isValidBase64(String base64String) {
    try {
      // Cek panjang string base64 harus kelipatan 4
      if (base64String.length % 4 != 0) {
        return false;
      }

      // Cek karakter yang valid
      final validChars = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (!validChars.hasMatch(base64String)) {
        return false;
      }

      // Test decode
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method untuk container error
  Widget _buildErrorContainer(String message) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detail Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: BlocConsumer<OrganisasiHomeBloc, OrganisasiHomeState>(
        listener: (context, state) {
          // Reset loading state
          if (state is! OrganisasiHomeLoading) {
            setState(() => _isLoading = false);
          }

          // Cache event detail ketika berhasil dimuat
          if (state is OrganisasiEventDetailLoaded) {
            _cachedEventDetail = state.detail;
          }

          if (state is OrganisasiPendaftarLoaded) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PendaftarListPage(eventId: widget.eventId),
              ),
            ).then((_) {
              // Setelah kembali dari halaman pendaftar, reload detail event
              if (mounted) {
                _loadEventDetail();
              }
            });
          }

          if (state is OrganisasiEventActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            if (state.message.toLowerCase().contains("hapus")) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context, true);
                }
              });
            }
          }

          if (state is OrganisasiHomeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal: ${state.error}"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrganisasiHomeLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Prioritaskan OrganisasiEventDetailLoaded, tapi jika tidak ada dan ada cache, gunakan cache
          EventData? eventData;
          if (state is OrganisasiEventDetailLoaded) {
            eventData = state.detail;
          } else if (_cachedEventDetail != null) {
            eventData = _cachedEventDetail;
          }

          if (eventData != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          eventData.nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detail lengkap event Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Gambar Event
                  _buildSectionTitle('Gambar Event', Icons.photo_camera),
                  _buildImageSection(eventData.photo),

                  const SizedBox(height: 24),

                  // Informasi Dasar
                  _buildSectionTitle('Informasi Dasar', Icons.info_outline),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          eventData.deskripsi,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Jadwal Event
                  _buildSectionTitle('Jadwal Event', Icons.schedule),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Tanggal Buka',
                          eventData.tglBuka,
                          Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Tanggal Tutup',
                          eventData.tglTutup,
                          Icons.event_busy,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Kapasitas & Lokasi
                  _buildSectionTitle('Kapasitas & Lokasi', Icons.place),
                  _buildInfoCard(
                    'Kuota Mahasiswa',
                    '${eventData.kuotaMahasiswa} mahasiswa',
                    Icons.people,
                  ),
                  if (eventData.alamat != null)
                    _buildInfoCard(
                      'Koordinat Lokasi',
                      '${eventData.alamat}',
                      Icons.location_on,
                    ),

                  const SizedBox(height: 24),

                  // Tombol Aksi
                  _buildSectionTitle('Aksi', Icons.settings),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                label: 'Edit',
                                icon: Icons.edit,
                                onPressed: () => _goToEdit(eventData!),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                label: 'Hapus',
                                icon: Icons.delete,
                                onPressed: () => _confirmDelete(eventData!.id),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _buildActionButton(
                            label: 'Lihat Pendaftar',
                            icon: Icons.people,
                            onPressed: _goToListPendaftar,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // // Ringkasan Pendaftar
                  // _buildSectionTitle('Ringkasan Pendaftar', Icons.analytics),
                  // BlocBuilder<OrganisasiHomeBloc, OrganisasiHomeState>(
                  //   builder: (context, pendaftarState) {
                  //     if (pendaftarState is OrganisasiPendaftarLoaded) {
                  //       final pendaftar = pendaftarState.pendaftar;
                  //       final disetujui =
                  //           pendaftar
                  //               .where((p) => p.status == 'disetujui')
                  //               .length;
                  //       final pending =
                  //           pendaftar
                  //               .where((p) => p.status == 'pending')
                  //               .length;
                  //       final ditolak =
                  //           pendaftar
                  //               .where((p) => p.status == 'ditolak')
                  //               .length;

                  //       return Container(
                  //         padding: const EdgeInsets.all(20),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(15),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.grey.withOpacity(0.1),
                  //               spreadRadius: 1,
                  //               blurRadius: 8,
                  //               offset: const Offset(0, 2),
                  //             ),
                  //           ],
                  //         ),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 Container(
                  //                   padding: const EdgeInsets.all(8),
                  //                   decoration: BoxDecoration(
                  //                     color: Theme.of(
                  //                       context,
                  //                     ).primaryColor.withOpacity(0.1),
                  //                     borderRadius: BorderRadius.circular(8),
                  //                   ),
                  //                   child: Icon(
                  //                     Icons.group,
                  //                     color: Theme.of(context).primaryColor,
                  //                     size: 20,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 12),
                  //                 Text(
                  //                   'Total Pendaftar: ${pendaftar.length}',
                  //                   style: const TextStyle(
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 16,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             const SizedBox(height: 20),
                  //             Row(
                  //               children: [
                  //                 Expanded(
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(16),
                  //                     decoration: BoxDecoration(
                  //                       color: Colors.green.withOpacity(0.1),
                  //                       borderRadius: BorderRadius.circular(12),
                  //                     ),
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           '$disetujui',
                  //                           style: const TextStyle(
                  //                             color: Colors.green,
                  //                             fontWeight: FontWeight.bold,
                  //                             fontSize: 24,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(height: 4),
                  //                         const Text(
                  //                           'Disetujui',
                  //                           style: TextStyle(
                  //                             color: Colors.green,
                  //                             fontWeight: FontWeight.w600,
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 12),
                  //                 Expanded(
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(16),
                  //                     decoration: BoxDecoration(
                  //                       color: Colors.orange.withOpacity(0.1),
                  //                       borderRadius: BorderRadius.circular(12),
                  //                     ),
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           '$pending',
                  //                           style: const TextStyle(
                  //                             color: Colors.orange,
                  //                             fontWeight: FontWeight.bold,
                  //                             fontSize: 24,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(height: 4),
                  //                         const Text(
                  //                           'Pending',
                  //                           style: TextStyle(
                  //                             color: Colors.orange,
                  //                             fontWeight: FontWeight.w600,
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 12),
                  //                 Expanded(
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(16),
                  //                     decoration: BoxDecoration(
                  //                       color: Colors.red.withOpacity(0.1),
                  //                       borderRadius: BorderRadius.circular(12),
                  //                     ),
                  //                     child: Column(
                  //                       children: [
                  //                         Text(
                  //                           '$ditolak',
                  //                           style: const TextStyle(
                  //                             color: Colors.red,
                  //                             fontWeight: FontWeight.bold,
                  //                             fontSize: 24,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(height: 4),
                  //                         const Text(
                  //                           'Ditolak',
                  //                           style: TextStyle(
                  //                             color: Colors.red,
                  //                             fontWeight: FontWeight.w600,
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     }

                  //     return Container(
                  //       padding: const EdgeInsets.all(20),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(15),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.grey.withOpacity(0.1),
                  //             spreadRadius: 1,
                  //             blurRadius: 8,
                  //             offset: const Offset(0, 2),
                  //           ),
                  //         ],
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           const SizedBox(
                  //             width: 20,
                  //             height: 20,
                  //             child: CircularProgressIndicator(strokeWidth: 2),
                  //           ),
                  //           const SizedBox(width: 16),
                  //           Text(
                  //             'Memuat data pendaftar...',
                  //             style: TextStyle(
                  //               color: Colors.grey.shade600,
                  //               fontSize: 14,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          if (state is OrganisasiHomeFailure) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Gagal Memuat Detail',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadEventDetail,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat detail event...'),
              ],
            ),
          );
        },
      ),
    );
  }
}
