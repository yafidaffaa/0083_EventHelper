import 'package:eventhelper_fe/data/model/response/organisasi/event_response_model.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/home/organisasi_home_bloc.dart';
import 'package:eventhelper_fe/pages/organisasi/bloc/profile/profile_bloc.dart';
import 'package:eventhelper_fe/pages/organisasi/home/organisasi_event_detail_page.dart';
import 'package:eventhelper_fe/pages/organisasi/home/organisasi_event_form_page.dart';
import 'package:eventhelper_fe/pages/organisasi/profile/organisasi_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

class OrganisasiHomePage extends StatefulWidget {
  const OrganisasiHomePage({super.key});

  @override
  State<OrganisasiHomePage> createState() => _OrganisasiHomePageState();
}

class _OrganisasiHomePageState extends State<OrganisasiHomePage>
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        TickerProviderStateMixin {
  int _currentIndex = 0;
  List<EventData> _cachedEvents = []; // Cache events locally
  bool _needsRefresh = false;
  bool _isFirstLoad = true;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    // Load initial data with delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsWithDelay();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _needsRefresh) {
      _loadEvents();
      _needsRefresh = false;
    }
  }

  void _loadEventsWithDelay() async {
    // Add small delay for first load
    await Future.delayed(const Duration(milliseconds: 300));
    _loadEvents();
  }

  void _loadEvents() {
    try {
      dev.log('Loading events...');
      context.read<OrganisasiHomeBloc>().add(LoadMyEvents());
    } catch (e) {
      dev.log('Error loading events: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: ${e.toString()}'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _goToAddEvent() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrganisasiEventFormPage()),
      );

      if (result == true && mounted) {
        _loadEvents();
      }
    } catch (e) {
      dev.log('Error navigating to add event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onEventTap(EventData event) async {
    try {
      // Set flag bahwa kita perlu refresh
      _needsRefresh = true;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrganisasiEventDetailPage(eventId: event.id),
        ),
      );

      // Refresh jika ada perubahan atau user kembali
      if (mounted) {
        _needsRefresh = false;
        _loadEvents();
      }
    } catch (e) {
      dev.log('Error navigating to event detail: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
                  // Logo/Icon Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      size: 40,
                      color: Colors.white,
                    ),
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
                    'Organisasi Dashboard',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                OrganisasiEventList(
                  onEventTap: _onEventTap,
                  onRefresh: _loadEvents,
                  slideAnimation: _slideAnimation,
                  cachedEvents: _cachedEvents,
                ),
                const OrganisasiProfilePage(),
              ],
            ),
          ),
        ],
      ),

      // Add Event FAB
      floatingActionButton:
          _currentIndex == 0
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
                child: FloatingActionButton(
                  onPressed: _goToAddEvent,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              )
              : null,

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
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrganisasiProfilePage(),
                ),
              );
            } else {
              setState(() => _currentIndex = index);
              _loadEvents();
            }
          },
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

class OrganisasiEventList extends StatefulWidget {
  final Function(EventData) onEventTap;
  final VoidCallback onRefresh;
  final Animation<double> slideAnimation;
  final List<EventData> cachedEvents;

  const OrganisasiEventList({
    super.key,
    required this.onEventTap,
    required this.onRefresh,
    required this.slideAnimation,
    required this.cachedEvents,
  });

  @override
  State<OrganisasiEventList> createState() => _OrganisasiEventListState();
}

class _OrganisasiEventListState extends State<OrganisasiEventList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildEventCard(EventData event, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onEventTap(event),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Color(0xFF667eea),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kuota: ${event.kuotaMahasiswa} orang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.date_range,
                                size: 16,
                                color: Color(0xFF667eea),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${event.tglBuka} s.d. ${event.tglTutup}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(widget.slideAnimation),
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
              'Tap tombol + untuk menambah event baru',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
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
              'Memuat data event...',
              style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              _getErrorMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
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
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('FormatException')) {
      return 'Server tidak memberikan response yang valid.\nCoba lagi nanti.';
    } else if (error.contains('SocketException')) {
      return 'Tidak dapat terhubung ke server.\nPastikan koneksi internet Anda aktif.';
    } else if (error.contains('TimeoutException')) {
      return 'Koneksi timeout.\nCoba lagi nanti.';
    } else {
      return error.length > 100 ? '${error.substring(0, 100)}...' : error;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<OrganisasiHomeBloc, OrganisasiHomeState>(
      listener: (context, state) {
        if (state is OrganisasiHomeFailure) {
          dev.log('OrganisasiHomeFailure: ${state.error}');

          // Don't show snackbar if it's a format exception, let the UI handle it
          if (!state.error.contains('FormatException')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${_getErrorMessage(state.error)}'),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: widget.onRefresh,
                  textColor: Colors.white,
                ),
              ),
            );
          }
        }

        if (state is OrganisasiEventListLoaded) {
          dev.log('Events loaded: ${state.events.length}');
        }
      },
      builder: (context, state) {
        dev.log('Current state: ${state.runtimeType}');

        // Handle different states
        if (state is OrganisasiHomeLoading) {
          return _buildLoadingState();
        }

        if (state is OrganisasiEventListLoaded) {
          final events = state.events;

          if (events.isEmpty) {
            return _buildEmptyState();
          }

          return Transform.translate(
            offset: const Offset(0, -20),
            child: RefreshIndicator(
              onRefresh: () async {
                widget.onRefresh();
                await Future.delayed(const Duration(milliseconds: 1000));
              },
              color: const Color(0xFF667eea),
              backgroundColor: Colors.white,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event, index);
                },
              ),
            ),
          );
        }

        if (state is OrganisasiHomeFailure) {
          return _buildErrorState(state.error);
        }

        // Default state - show empty state
        return _buildEmptyState();
      },
    );
  }
}
