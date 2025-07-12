import 'dart:convert';
import 'dart:io';

import 'package:eventhelper_fe/data/model/request/organisasi/event_request_model.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/home/organisasi_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class OrganisasiEventFormPage extends StatefulWidget {
  final EventData? event; // null berarti tambah baru

  const OrganisasiEventFormPage({super.key, this.event});

  @override
  State<OrganisasiEventFormPage> createState() =>
      _OrganisasiEventFormPageState();
}

class _OrganisasiEventFormPageState extends State<OrganisasiEventFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tglBukaController = TextEditingController();
  final _tglTutupController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _alamatController = TextEditingController();

  File? _pickedImage;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final e = widget.event!;
      _namaController.text = e.nama;
      _deskripsiController.text = e.deskripsi;
      _tglBukaController.text = e.tglBuka;
      _tglTutupController.text = e.tglTutup;
      _kuotaController.text = e.kuotaMahasiswa.toString();
      _alamatController.text = e.alamat ?? '';
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial =
        controller.text.isNotEmpty
            ? DateTime.parse(controller.text)
            : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Method untuk menampilkan opsi pemilihan gambar
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text('Kamera'),
                  subtitle: const Text('Ambil foto dengan kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.green),
                  ),
                  title: const Text('Galeri'),
                  subtitle: const Text('Pilih dari galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_pickedImage != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    title: const Text('Hapus Gambar'),
                    subtitle: const Text('Hapus gambar yang dipilih'),
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk memilih gambar dari sumber tertentu
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method untuk menghapus gambar
  void _removeImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  // Method untuk memeriksa dan meminta permission location
  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.location.request();
    return result.isGranted;
  }

  // Method untuk mendapatkan lokasi saat ini
  Future<LatLng?> _getCurrentLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission lokasi diperlukan untuk menggunakan fitur ini',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi tidak aktif'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Method untuk mendapatkan alamat dari koordinat
  Future<String> _getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
      }

      return '${location.latitude}, ${location.longitude}';
    } catch (e) {
      return '${location.latitude}, ${location.longitude}';
    }
  }

  // Method untuk menampilkan map picker
  void _showMapPicker() async {
    LatLng? initialLocation = _selectedLocation;

    // Jika belum ada lokasi yang dipilih, gunakan lokasi saat ini
    if (initialLocation == null) {
      initialLocation = await _getCurrentLocation();
      if (initialLocation == null) {
        // Jika gagal mendapatkan lokasi, gunakan koordinat default (Jakarta)
        initialLocation = const LatLng(-6.2088, 106.8456);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapPickerDialog(
          initialLocation: initialLocation!,
          onLocationSelected: (LatLng location) async {
            setState(() {
              _selectedLocation = location;
            });

            // Dapatkan alamat dari koordinat
            final address = await _getAddressFromLatLng(location);
            setState(() {
              _alamatController.text = address;
            });
          },
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final photoBase64 =
          _pickedImage != null
              ? base64Encode(_pickedImage!.readAsBytesSync())
              : widget.event?.photo; // keep previous if editing & not changed

      final request = EventRequestModel(
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        tglBuka: _tglBukaController.text,
        tglTutup: _tglTutupController.text,
        kuotaMahasiswa: int.parse(_kuotaController.text),
        alamat: _alamatController.text,
        photo: photoBase64,
      );

      if (widget.event == null) {
        context.read<OrganisasiHomeBloc>().add(CreateEvent(request));
      } else {
        context.read<OrganisasiHomeBloc>().add(
          UpdateEvent(widget.event!.id, request),
        );
      }

      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
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
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
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

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          if (_pickedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _pickedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _removeImage,
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Tombol untuk memilih gambar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.blue.shade400),
                    foregroundColor: Colors.blue.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.green.shade400),
                    foregroundColor: Colors.green.shade400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tombol untuk membuka dialog
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                _pickedImage != null
                    ? 'Ganti Gambar Event'
                    : 'Tambah Gambar Event',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Event' : 'Tambah Event',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                ),
                child: Column(
                  children: [
                    Icon(
                      isEditing
                          ? Icons.edit_outlined
                          : Icons.add_circle_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing ? 'Edit Event' : 'Buat Event Baru',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Perbarui informasi event Anda'
                          : 'Isi form di bawah untuk membuat event baru',
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

              // Informasi Dasar
              _buildSectionTitle('Informasi Dasar', Icons.info_outline),
              _buildTextField(
                controller: _namaController,
                label: 'Nama Event',
                icon: Icons.event,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              _buildTextField(
                controller: _deskripsiController,
                label: 'Deskripsi',
                icon: Icons.description,
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),

              // Jadwal Event
              _buildSectionTitle('Jadwal Event', Icons.schedule),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tglBukaController,
                      label: 'Tanggal Buka',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _pickDate(_tglBukaController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _tglTutupController,
                      label: 'Tanggal Tutup',
                      icon: Icons.event_busy,
                      readOnly: true,
                      onTap: () => _pickDate(_tglTutupController),
                    ),
                  ),
                ],
              ),

              // Kapasitas & Lokasi
              _buildSectionTitle('Kapasitas & Lokasi', Icons.place),
              _buildTextField(
                controller: _kuotaController,
                label: 'Kuota Mahasiswa',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              _buildTextField(
                controller: _alamatController,
                label: 'Alamat Lokasi Event',
                icon: Icons.place,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                readOnly: true,
                onTap: _showMapPicker,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onPressed: _showMapPicker,
                  tooltip: 'Pilih lokasi di peta',
                ),
              ),

              // Gambar Event
              _buildSectionTitle('Gambar Event', Icons.photo_camera),
              _buildImageSection(),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog untuk memilih lokasi di peta
class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;

  const MapPickerDialog({
    Key? key,
    required this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late GoogleMapController _mapController;
  late LatLng _currentLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _currentLocation,
        draggable: true,
        onDragEnd: (LatLng position) {
          setState(() {
            _currentLocation = position;
          });
        },
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _currentLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _currentLocation = newPosition;
            });
          },
        ),
      );
    });
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: newLocation,
            draggable: true,
            onDragEnd: (LatLng position) {
              setState(() {
                _currentLocation = position;
              });
            },
          ),
        );
      });

      _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pilih Lokasi Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Current location button
                  FloatingActionButton(
                    mini: true,
                    heroTag: "current_location",
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                  const SizedBox(width: 16),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onLocationSelected(_currentLocation);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Pilih Lokasi Ini'),
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
          ],
        ),
      ),
    );
  }
}
