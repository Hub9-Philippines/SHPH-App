import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart' hide LatLng;
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import '/index.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import '../../pages/booking_funnel/widgets/booking_flow_route.dart';
import '../../pages/booking_funnel/widgets/service_selection_panel.dart';
import 'home_model.dart';

export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;
  late Future<List<AddressesRow>> _addressFuture;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;
  LatLng _center = const LatLng(14.5995, 120.9842);
  bool _hasLocation = false;
  bool _isUsingDeviceLocation = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, HomeModel.new);
    _loadAddress();
    _loadDeviceLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AddressesRow>>(
        future: _addressFuture,
        builder: (context, snapshot) {
          final appState = context.watch<FFAppState>();
          final mediaQuery = MediaQuery.of(context);
          final mapPadding = EdgeInsets.only(
            top: mediaQuery.padding.top + 132,
            right: 16,
            bottom: mediaQuery.padding.bottom + 248,
          );
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: AppTheme.of(context).primaryBackground,
              body: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: SpinKitThreeBounce(
                    color: AppTheme.of(context).primary,
                    size: 30,
                  ),
                ),
              ),
            );
          }

          final homeAddressesRowList = snapshot.data!;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) {
                  return;
                }
                if (!GoRouter.of(context).canPop()) {
                  final shouldExit = await _showExitConfirmation();
                  if (shouldExit && mounted) {
                    await SystemNavigator.pop();
                  }
                } else {
                  if (mounted) {
                    context.pop();
                  }
                }
              },
              child: Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: AppTheme.of(context).primaryBackground,
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 16,
                        ),
                        myLocationEnabled: _hasLocation,
                        myLocationButtonEnabled: _hasLocation,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        //markers: _homeMarkers(appState),
                        padding: mapPadding,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_isUsingDeviceLocation) {
                            _animateToCenter();
                          }
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.06),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.12),
                              ],
                              stops: const [0, 0.35, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _buildTopOverlay(),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildBottomCard(appState, homeAddressesRowList),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  void _loadAddress() {
    if (currentUserUid.isEmpty) {
      _addressFuture = Future.value(<AddressesRow>[]);
      return;
    }
    _addressFuture = FFAppState()
        .getAddress(
      uniqueQueryKey: 'address_$currentUserUid',
      requestFn: () => AddressesTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
      ),
    )
        .catchError((error) {
      LoggingService.error(
        'Failed to load address: $error',
        tag: 'Home',
        error: error,
      );
      return <AddressesRow>[];
    }).then((rows) {
      if (rows.isEmpty) {
        return rows;
      }

      final appState = FFAppState();
      if (appState.selectedLocationMode != 'saved') {
        return rows;
      }

      AddressesRow? selectedRow;

      final selectedId = appState.selectedAddressId;
      if (selectedId != null) {
        for (final row in rows) {
          if (row.id == selectedId) {
            selectedRow = row;
            break;
          }
        }
      }

      selectedRow ??= rows.cast<AddressesRow?>().firstWhere(
            (row) => row?.isDefault == true,
            orElse: () => null,
          );
      selectedRow ??= rows.first;

      appState.setSelectedAddressFromRow(selectedRow);
      final latitude = selectedRow.latitude;
      final longitude = selectedRow.longitude;
      if (latitude != null && longitude != null && mounted) {
        final target = LatLng(latitude, longitude);
        setState(() {
          _center = target;
          _isUsingDeviceLocation = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animateToCenter();
        });
      }
      return rows;
    });
  }

  Future<void> _loadDeviceLocation({bool forceUseDevice = false}) async {
    try {
      final position = await _determineCurrentPosition();
      if (!mounted) {
        return;
      }

      final appState = FFAppState();
      final nextCenter = LatLng(position.latitude, position.longitude);
      if (!forceUseDevice && appState.selectedLocationMode == 'saved') {
        setState(() {
          _hasLocation = true;
        });
        return;
      }

      appState.setSelectedDeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {
        _hasLocation = true;
        _isUsingDeviceLocation = true;
        _center = nextCenter;
      });
      await _animateToCenter();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasLocation = false;
      });
    }
  }

  Future<Position> _determineCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _animateToCenter() async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _center, zoom: 15.5),
      ),
    );
  }

  Widget _buildTopOverlay() => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'searchBarHero',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openSearchPage,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF5F6B76),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search services...',
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(),
                                    color: const Color(0xFF6A7681),
                                    fontSize: 15,
                                  ),
                            ),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () => context.pushNamed(
                                  MyNotificationsWidget.routeName,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: Color(0xFF17212B),
                                    size: 24,
                                  ),
                                ),
                              ),
                              if (_model.notificationCount > 0)
                                Positioned(
                                  top: 0,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).error,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      _model.notificationCount > 99
                                          ? '99+'
                                          : _model.notificationCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildCategoryChip(
                      icon: Icons.cleaning_services_rounded,
                      label: 'Cleaning',
                      onTap: () => context.pushNamed(
                        ServicesScreen.routeName,
                        extra: <String, dynamic>{
                          'initialCategory': 'Cleaning',
                        },
                      ),
                    ),
                    _buildCategoryChip(
                      icon: Icons.plumbing_rounded,
                      label: 'Plumbing',
                      onTap: () => context.pushNamed(
                        ServicesScreen.routeName,
                        extra: <String, dynamic>{
                          'initialCategory': 'Plumbing',
                        },
                      ),
                    ),
                    _buildCategoryChip(
                      icon: Icons.electrical_services_rounded,
                      label: 'Electrical',
                      onTap: () => context.pushNamed(
                        ServicesScreen.routeName,
                        extra: <String, dynamic>{
                          'initialCategory': 'Electrical',
                        },
                      ),
                    ),
                    _buildCategoryChip(
                      icon: Icons.format_paint_rounded,
                      label: 'Painting',
                      onTap: () => context.pushNamed(
                        ServicesScreen.routeName,
                        extra: <String, dynamic>{
                          'initialCategory': 'Painting & Decorating',
                        },
                      ),
                    ),
                    _buildCategoryChip(
                      icon: Icons.grid_view_rounded,
                      label: 'More',
                      onTap: () => context.pushNamed(
                        CategoriesWidget.routeName,
                        extra: <String, dynamic>{
                          '__transition_info__': const TransitionInfo(
                            hasTransition: true,
                            transitionType: TransitionType.bottomToTop,
                            duration: Duration(milliseconds: 100),
                          ),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: const Color(0xFF17212B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          color: const Color(0xFF17212B),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildBottomCard(
    FFAppState appState,
    List<AddressesRow> addresses,
  ) =>
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DBE1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Booking starts from your pinned location',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).labelMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppTheme.of(context).primary,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startBookingProcess,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary.withValues(
                              alpha: 0.1,
                            ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Book a Service',
                                  style:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF16202A),
                                          ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap here to get a professional to your destination',
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.poppins(),
                                            color: const Color(0xFF63707C),
                                          ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primary.withValues(
                                    alpha: 0.16,
                                  ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.handyman_rounded,
                              color: AppTheme.of(context).primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _openLocationSheet(snapshotAddresses: addresses),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E9EE)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7FA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.location_history_rounded,
                              color: Color(0xFF53606D),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pin location',
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.poppins(),
                                            color: const Color(0xFF7A8793),
                                          ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _addressText(appState),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            color: const Color(0xFF16202A),
                                          ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF53606D),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _openLocationSheet({
    List<AddressesRow>? snapshotAddresses,
  }) async {
    final addresses = snapshotAddresses ??
        await _addressFuture.catchError((_) => <AddressesRow>[]);
    if (!mounted) {
      return;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: _HomeLocationSheet(
            addresses: addresses,
            hasDeviceLocation: _hasLocation,
            selectedAddressId: FFAppState().selectedAddressId,
            selectedLocationMode: FFAppState().selectedLocationMode,
            onUseCurrentLocation:
                _hasLocation ? _selectCurrentDeviceLocation : null,
            onSelectSavedAddress: _selectSavedAddress,
            onAddAddress: () async {
              Navigator.of(context).pop();
              await context.pushNamed(AddressFormWidget.routeName);
              if (mounted) {
                safeSetState(_loadAddress);
              }
            },
          ),
        ),
      ),
    ).then((_) => safeSetState(_loadAddress));
  }

  Future<void> _startBookingProcess() async {
    final selectedService = await showModalBottomSheet<ServiceListing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceSelectionPanel(
        locationLabel: _addressText(FFAppState()),
      ),
    );
    if (!mounted || selectedService == null) {
      return;
    }

    await Navigator.of(context).push(
      buildBookingFlowRoute(
        CleaningBookingFlowScreen(selectedService: selectedService),
      ),
    );
  }

  Future<void> _openSearchPage() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchPageWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: fade,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _selectCurrentDeviceLocation() async {
    try {
      final position = await _determineCurrentPosition();
      if (!mounted) {
        return;
      }

      FFAppState().setSelectedDeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {
        _hasLocation = true;
        _center = LatLng(position.latitude, position.longitude);
        _isUsingDeviceLocation = true;
      });
      Navigator.of(context).pop();
      await _animateToCenter();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasLocation = false;
      });
    }
  }

  Future<void> _selectSavedAddress(AddressesRow address) async {
    final latitude = address.latitude;
    final longitude = address.longitude;
    FFAppState().setSelectedAddressFromRow(address);
    if (mounted && latitude != null && longitude != null) {
      setState(() {
        _center = LatLng(latitude, longitude);
        _isUsingDeviceLocation = false;
      });
      Navigator.of(context).pop();
      await _animateToCenter();
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Set<Marker> _homeMarkers(FFAppState appState) {
    if (appState.selectedLocationMode != 'saved') {
      return const <Marker>{};
    }

    final latitude = appState.selectedLatitude;
    final longitude = appState.selectedLongitude;
    if (latitude == null || longitude == null) {
      return const <Marker>{};
    }

    return {
      Marker(
        markerId: const MarkerId('selected_home_location'),
        position: LatLng(latitude, longitude),
      ),
    };
  }

  String _addressText(FFAppState appState) {
    if (appState.selectedLocationMode == 'device' && _hasLocation) {
      return 'Current device location';
    }

    if (appState.selectedAddressLine1.isNotEmpty) {
      return appState.selectedAddressLine1;
    }
    if (appState.selectedAddressLabel.isNotEmpty) {
      return appState.selectedAddressLabel;
    }
    return 'Select your location';
  }

  Future<bool> _showExitConfirmation() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        ),
      ) ??
      false;
}

class _HomeLocationSheet extends StatelessWidget {
  const _HomeLocationSheet({
    required this.addresses,
    required this.hasDeviceLocation,
    required this.selectedAddressId,
    required this.selectedLocationMode,
    required this.onUseCurrentLocation,
    required this.onSelectSavedAddress,
    required this.onAddAddress,
  });

  final List<AddressesRow> addresses;
  final bool hasDeviceLocation;
  final int? selectedAddressId;
  final String selectedLocationMode;
  final VoidCallback? onUseCurrentLocation;
  final ValueChanged<AddressesRow> onSelectSavedAddress;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DBE1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose location',
                style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  color: const Color(0xFF16202A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use your live device location or one of your saved addresses.',
                style: theme.bodySmall.override(
                  font: GoogleFonts.poppins(),
                  color: const Color(0xFF66727E),
                ),
              ),
              const SizedBox(height: 18),
              _HomeLocationOption(
                icon: Icons.my_location_rounded,
                title: 'Current device location',
                subtitle: hasDeviceLocation
                    ? 'Use your live phone location on the map'
                    : 'Enable location services to use this option',
                isSelected:
                    selectedLocationMode == 'device' && hasDeviceLocation,
                isEnabled: hasDeviceLocation,
                onTap: onUseCurrentLocation,
              ),
              if (addresses.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Saved addresses',
                  style: theme.labelLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF16202A),
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _HomeLocationOption(
                        icon: _addressIcon(address.addressLine2),
                        title: address.addressLine2?.trim().isNotEmpty == true
                            ? address.addressLine2!.trim()
                            : 'Saved address',
                        subtitle: [
                          address.addressLine1,
                          address.city,
                        ]
                            .whereType<String>()
                            .where((e) => e.trim().isNotEmpty)
                            .join(', '),
                        isSelected: selectedLocationMode == 'saved' &&
                            selectedAddressId == address.id,
                        onTap: () => onSelectSavedAddress(address),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddAddress,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add new address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _addressIcon(String? label) {
    final normalized = label?.toLowerCase().trim() ?? '';
    if (normalized.contains('home')) {
      return Icons.home_rounded;
    }
    if (normalized.contains('work') || normalized.contains('office')) {
      return Icons.work_rounded;
    }
    return Icons.location_on_rounded;
  }
}

class _HomeLocationOption extends StatelessWidget {
  const _HomeLocationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    this.isEnabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.08)
                  : Colors.white,
              border: Border.all(
                color: isSelected ? theme.primary : const Color(0xFFE5E9EE),
                width: isSelected ? 1.4 : 1,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primary.withValues(alpha: 0.12)
                        : const Color(0xFFF4F7FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? theme.primary : const Color(0xFF53606D),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.bodyMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          color: const Color(0xFF16202A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: const Color(0xFF6F7B86),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? theme.primary : const Color(0xFF9AA6B2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
