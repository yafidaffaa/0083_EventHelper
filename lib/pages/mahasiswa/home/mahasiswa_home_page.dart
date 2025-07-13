// MahasiswaHomePage dengan error handling yang lebih baik
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/data/model/response/mahasiswa/event_mahasiswa_response_model.dart';
import 'package:eventhelper_fe/pages/mahasiswa/bloc/home/home_bloc.dart';
import 'package:eventhelper_fe/pages/mahasiswa/home/mahasiswa_event_detail_page.dart';
import 'package:eventhelper_fe/pages/mahasiswa/profile/mahasiswa_profile_page.dart';

class MahasiswaHomePage extends StatefulWidget {
  const MahasiswaHomePage({Key? key}) : super(key: key);

  @override
  State<MahasiswaHomePage> createState() => _MahasiswaHomePageState();
}

class _MahasiswaHomePageState extends State<MahasiswaHomePage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  // Controllers dan variables untuk search dan filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _filterType = 'semua'; // 'semua', 'terdaftar', 'belum_terdaftar'
  bool _showFilters = false;

  // Data untuk filtering
  List<EventData> _allEvents = [];
  List<EventMahasiswaResponseModel> _registeredEvents = [];
  List<EventData> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _loadEvents() {
    context.read<MahasiswaHomeBloc>().add(LoadMahasiswaProfileHome());
    context.read<MahasiswaHomeBloc>().add(LoadAllEvent());
    context.read<MahasiswaHomeBloc>().add(LoadEventYangDiikuti());
  }

  // Helper function untuk safely get string dari dynamic value
  String _safeGetString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map) return value.toString();
    return value.toString();
  }

  // Helper function untuk safely parse date
  DateTime? _safeParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString - $e');
      return null;
    }
  }

  void _applyFilters() {
    List<EventData> filtered = List.from(_allEvents);

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((event) {
            final eventName = _safeGetString(event.nama).toLowerCase();
            return eventName.contains(_searchQuery.toLowerCase());
          }).toList();
    }

    // Filter berdasarkan tanggal
    if (_startDate != null && _endDate != null) {
      filtered =
          filtered.where((event) {
            final eventDate = _safeParseDate(event.tglBuka);
            if (eventDate == null)
              return true; // Jika parsing gagal, tetap tampilkan event

            return eventDate.isAfter(
                  _startDate!.subtract(const Duration(days: 1)),
                ) &&
                eventDate.isBefore(_endDate!.add(const Duration(days: 1)));
          }).toList();
    }

    // Filter berdasarkan status pendaftaran
    if (_filterType == 'terdaftar') {
      final registeredEventIds =
          _registeredEvents.map((e) => e.eventId).toSet();
      filtered =
          filtered
              .where((event) => registeredEventIds.contains(event.id))
              .toList();
    } else if (_filterType == 'belum_terdaftar') {
      final registeredEventIds =
          _registeredEvents.map((e) => e.eventId).toSet();
      filtered =
          filtered
              .where((event) => !registeredEventIds.contains(event.id))
              .toList();
    }

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MahasiswaProfilePage()),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF667eea)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari event...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: const Color(0xFF667eea),
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Event',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),

          // Filter berdasarkan status pendaftaran
          const Text(
            'Status Pendaftaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: _filterType == 'semua',
                onSelected: (bool selected) {
                  setState(() {
                    _filterType = 'semua';
                    _applyFilters();
                  });
                },
                selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                checkmarkColor: const Color(0xFF667eea),
              ),
              FilterChip(
                label: const Text('Terdaftar'),
                selected: _filterType == 'terdaftar',
                onSelected: (bool selected) {
                  setState(() {
                    _filterType = 'terdaftar';
                    _applyFilters();
                  });
                },
                selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                checkmarkColor: const Color(0xFF667eea),
              ),
              FilterChip(
                label: const Text('Belum Terdaftar'),
                selected: _filterType == 'belum_terdaftar',
                onSelected: (bool selected) {
                  setState(() {
                    _filterType = 'belum_terdaftar';
                    _applyFilters();
                  });
                },
                selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                checkmarkColor: const Color(0xFF667eea),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter berdasarkan tanggal
          const Text(
            'Rentang Tanggal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                        : 'Pilih Tanggal',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (_startDate != null && _endDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearDateFilter,
                  icon: const Icon(Icons.clear, color: Colors.red),
                  tooltip: 'Hapus Filter Tanggal',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
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
                  child: const Icon(Icons.event, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'EVENT HELPER',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mahasiswa Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          _buildSearchBar(),

          // Filter Section
          _buildFilterSection(),

          if (_showFilters) const SizedBox(height: 8),

          // Content
          Expanded(
            child: BlocListener<MahasiswaHomeBloc, MahasiswaHomeState>(
              listener: (context, state) {
                if (state is MahasiswaAllEventListLoaded) {
                  _allEvents = state.eventList;
                  _applyFilters();
                } else if (state is MahasiswaRegisteredEventListLoaded) {
                  _registeredEvents = state.eventList;
                  _applyFilters();
                }
              },
              child: BlocBuilder<MahasiswaHomeBloc, MahasiswaHomeState>(
                builder: (context, state) {
                  if (state is MahasiswaHomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667eea),
                        ),
                      ),
                    );
                  } else if (state is MahasiswaHomeFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Gagal memuat event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadEvents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tampilkan hasil filter
                  if (_filteredEvents.isEmpty && _allEvents.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.search_off,
                              size: 48,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Event tidak ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba ubah kata kunci pencarian atau filter.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredEvents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Belum ada event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan refresh halaman untuk memuat event terbaru.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadEvents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadEvents(),
                    color: const Color(0xFF667eea),
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        final isRegistered = _registeredEvents.any(
                          (reg) => reg.eventId == event.id,
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _safeGetString(event.nama),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ),
                                if (isRegistered)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Terdaftar',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Tanggal Buka: ${_safeGetString(event.tglBuka)}',
                                ),
                                Text(
                                  'Tanggal Tutup: ${_safeGetString(event.tglTutup)}',
                                ),
                                Text(
                                  'Kuota: ${_safeGetString(event.kuotaMahasiswa)} mahasiswa',
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF667eea),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MahasiswaEventDetailPage(
                                        event: event,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
