import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart' hide LatLng;
import '/components/category_pill.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import '/index.dart';
import '/models/service_listing.dart';
import '/pages/booking_funnel/booking_controller.dart';
import '/pages/booking_funnel/booking_models.dart';
import '/pages/booking_funnel/express_checkout_screen.dart';
import '/pages/booking_funnel/live_matching/live_matching_screen.dart';
import '/pages/booking_funnel/status_page.dart';
import '/services/ai_service.dart';
import '/services/categories_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import '/utils/geo_utils.dart';
import '../../components/section_header.dart';
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
  late final List<_ActiveBookingShortcutData> _activeBookingShortcuts;
  List<ServiceListing>? _aiRecommendations;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, HomeModel.new);
    _activeBookingShortcuts = _buildActiveBookingShortcuts();
    _loadAddress();
    _loadDeviceLocation();
    _loadAiRecommendations();
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
          final activeShortcut = _visibleActiveBookingShortcut();

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
                if (didPop) return;
                if (!GoRouter.of(context).canPop()) {
                  final shouldExit = await _showExitConfirmation();
                  if (shouldExit && mounted) {
                    await SystemNavigator.pop();
                  }
                } else {
                  if (mounted) context.pop();
                }
              },
              child: Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: AppTheme.of(context).secondaryBackground,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderSection(context, appState),
                      _buildSearchBar(context, appState),
                      _buildCategoryChips(context),
                      if (activeShortcut != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: _buildActiveBookingBanner(
                            context,
                            activeShortcut,
                          ),
                        ),
                      _buildMapPreview(context, appState),
                      _buildBookServiceCTA(context),
                      _buildExploreServices(context),
                      _buildRecommendedPros(context),
                      if (AIService.instance.isAvailable)
                        _buildAiRecommendations(context),
                      _buildPinLocation(context, appState, homeAddressesRowList),
                      const SizedBox(height: 40),
                    ],
                  ),
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
      requestFn: () => AddressesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('user_id', currentUserUid)
            .order('is_default', ascending: false),
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
        final appState = FFAppState();
        if (appState.selectedLocationMode == 'saved') {
          appState.clearSelectedAddress();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadDeviceLocation(forceUseDevice: true);
          });
        }
        return rows;
      }

      final appState = FFAppState();
      if (appState.selectedLocationMode != 'saved') {
        return rows;
      }

      final selectedRow = appState.syncSelectedSavedAddress(rows);
      if (selectedRow == null) {
        return rows;
      }
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

  List<_ActiveBookingShortcutData> _buildActiveBookingShortcuts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      _ActiveBookingShortcutData(
        id: 'asap-live-001',
        providerName: 'Ramon Dela Cruz',
        serviceTitle: 'Home Cleaning',
        status: 'confirmation pending',
        urgency: 'ASAP',
        bookingDate: today,
        avatarUrl: '',
      ),
      _ActiveBookingShortcutData(
        id: 'scheduled-live-001',
        providerName: 'Assigned provider',
        serviceTitle: 'Repair Service',
        status: 'booking confirmed',
        urgency: 'scheduled',
        bookingDate: today,
        avatarUrl: '',
      ),
    ];
  }

  _ActiveBookingShortcutData? _visibleActiveBookingShortcut() {
    for (final booking in _activeBookingShortcuts) {
      final status = booking.status.toLowerCase();
      final isToday = _isSameCalendarDay(booking.bookingDate, DateTime.now());
      final isAsap = booking.urgency.toLowerCase() == 'asap';
      final isLiveStatus =
          status == 'confirmation pending' || status == 'booking confirmed';
      if ((isToday && isLiveStatus) || (isAsap && isLiveStatus)) {
        return booking;
      }
    }
    return null;
  }

  void _openActiveBooking(_ActiveBookingShortcutData booking) {
    final status = booking.status.toLowerCase();
    if (status == 'confirmation pending') {
      Navigator.of(context).push(
        buildBookingFlowRoute(
          LiveMatchingScreen(
            bookingDate: booking.bookingDate,
            serviceTitle: booking.serviceTitle,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatusPage(
          bookingStatus: booking.status,
          bookingDate: booking.bookingDate,
          providerName: booking.providerName,
          serviceTitle: booking.serviceTitle,
        ),
      ),
    );
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  Widget _buildHeaderSection(BuildContext context, FFAppState appState) {
    final theme = AppTheme.of(context);
    final avatarInitial = (currentUserDisplayName.isNotEmpty
            ? currentUserDisplayName[0]
            : 'U')
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        boxShadow: AppThemeData.shadowSoft,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'S',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'serbisyo',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: theme.primaryText,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => context.pushNamed(
                      MyNotificationsWidget.routeName,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: theme.primaryText,
                            size: 22,
                          ),
                        ),
                        if (appState.notificationCount > 0)
                          Positioned(
                            top: 0,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: theme.error,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: theme.primaryBackground,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                appState.notificationCount > 99
                                    ? '99+'
                                    : appState.notificationCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatarInitial,
                      style: GoogleFonts.poppins(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _openLocationSheet,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: theme.primaryBrandText,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _locationLabel(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: theme.primaryBrandText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: theme.primaryBrandText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _greeting(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find a trusted professional instantly',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, FFAppState appState) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openSearchPage,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppThemeData.shadowCard,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: theme.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Try "tulo sa sink" or "locksmith"...',
                    style: GoogleFonts.poppins(
                      color: theme.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 13,
                        color: theme.primaryBrandText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _locationLabel(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: theme.primaryBrandText,
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
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final chips = ['All', 'Cleaning', 'Plumbing', 'Electrical', 'Painting', 'Gardening'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => CategoryPill(
          label: chips[index],
          selected: index == 0,
          onTap: () {
            context.push('/search?category=${chips[index]}');
          },
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final prefix = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    final name = currentUserDisplayName.split(' ').firstOrNull ?? 'there';
    return '$prefix, $name!';
  }

  String _locationLabel() {
    final appState = FFAppState();
    if (appState.selectedAddressLabel.isNotEmpty) {
      return appState.selectedAddressLabel;
    }
    return 'My Location';
  }

  Widget _buildActiveBookingBanner(
    BuildContext context,
    _ActiveBookingShortcutData booking,
  ) {
    final theme = AppTheme.of(context);
    final status = booking.status.toLowerCase();
    final isConfirmationPending = status == 'confirmation pending';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: InkWell(
        onTap: () => _openActiveBooking(booking),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryLight,
              child: Icon(
                Icons.handyman_rounded,
                color: theme.primaryBrandText,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.serviceTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isConfirmationPending
                        ? 'Waiting for provider confirmation'
                        : 'Provider confirmed for today',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isConfirmationPending ? 'Pending' : 'Track',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, FFAppState appState) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppThemeData.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              myLocationEnabled: _hasLocation,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              markers: _homeMarkers(appState),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_isUsingDeviceLocation) {
                  _animateToCenter();
                }
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryBackground.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      size: 12,
                      color: theme.primaryBrandText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _addressText(appState),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: theme.primaryBrandText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookServiceCTA(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startBookingProcess,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary,
                  theme.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppThemeData.shadowElevated,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book a Service',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap here to get a professional to your destination',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handyman_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Explore Services',
            seeAllRoute: '/categories',
            padding: const EdgeInsets.only(bottom: 12),
          ),
          SizedBox(
            height: 220,
            child: _CategoriesPreviewGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedPros(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Trending Near You',
            seeAllRoute: '/tabs/explore',
            padding: const EdgeInsets.only(bottom: 12),
          ),
          SizedBox(
            height: 200,
            child: _ServiceListingsPreviewGrid(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAiRecommendations() async {
    if (!AIService.instance.isAvailable) return;
    final appState = FFAppState();
    final query = [
      appState.selectedAddressCity,
      appState.selectedAddressLabel,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(', ');
    final recommendations = await AIService.instance.getRecommendations(
      query: query.isNotEmpty ? query : null,
      limit: 6,
    );
    if (!mounted) return;
    setState(() => _aiRecommendations = recommendations);
  }

  Widget _buildAiRecommendations(BuildContext context) {
    if (_aiRecommendations == null || _aiRecommendations!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recommended for You',
            seeAllRoute: '/tabs/explore',
            padding: const EdgeInsets.only(bottom: 12),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _aiRecommendations!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = _aiRecommendations![index];
                return _ServiceCardItem(
                  title: service.title,
                  providerName: service.providerName ?? 'Provider',
                  categoryName: service.categoryName ?? '',
                  price: service.basePrice,
                  rating: service.rating,
                  thumbnail: service.thumbnail,
                  onTap: () {
                    context.push('/services/detail?id=${service.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinLocation(
    BuildContext context,
    FFAppState appState,
    List<AddressesRow> addresses,
  ) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLocationSheet(snapshotAddresses: addresses),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_history_rounded,
                    color: theme.secondaryText,
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _addressText(appState),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      builder: (_) => const ServiceSelectionPanel(),
    );
    if (!mounted || selectedService == null) {
      return;
    }

    await Navigator.of(context).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider(
          create: (_) => _buildController(selectedService),
          child: ExpressCheckoutScreen(service: selectedService),
        ),
      ),
    );
  }

  BookingFlowController _buildController(ServiceListing service) {
    final appState = FFAppState();
    final lat = appState.selectedLatitude ?? GeoUtils.fallbackLat;
    final lng = appState.selectedLongitude ?? GeoUtils.fallbackLng;
    return BookingFlowController(
      initialDraft: BookingDraft(
        urgency: BookingUrgency.rightNow,
        rooms: 1,
        cleaningType: ServiceType.standard,
        paymentMethod: BookingPaymentMethod.gcash,
        address: BookingAddress(
          label: appState.selectedAddressLabel.isNotEmpty
              ? appState.selectedAddressLabel
              : 'Pinned location',
          line1: appState.selectedAddressLine1.isNotEmpty
              ? appState.selectedAddressLine1
              : 'Pinned address',
          city: appState.selectedAddressCity.isNotEmpty
              ? appState.selectedAddressCity
              : 'Metro Manila',
        ),
        latitude: lat,
        longitude: lng,
      ),
    )..setService(service);
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

class _ActiveBookingShortcutData {
  const _ActiveBookingShortcutData({
    required this.id,
    required this.providerName,
    required this.serviceTitle,
    required this.status,
    required this.urgency,
    required this.bookingDate,
    required this.avatarUrl,
  });

  final String id;
  final String providerName;
  final String serviceTitle;
  final String status;
  final String urgency;
  final DateTime bookingDate;
  final String avatarUrl;
}

class _CategoriesPreviewGrid extends StatefulWidget {
  @override
  State<_CategoriesPreviewGrid> createState() => _CategoriesPreviewGridState();
}

class _CategoriesPreviewGridState extends State<_CategoriesPreviewGrid> {
  late Future<List<CategoriesRow>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoriesService.instance.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return FutureBuilder<List<CategoriesRow>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildSkeletonGrid(theme);
        }
        final categories = snapshot.data!.take(6).toList();
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.95,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _CategoryTileItem(
              name: cat.name,
              icon: _fallbackCategoryIcon(cat.name),
              onTap: () {
                context.push('/services?category=${cat.name}');
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonGrid(AppThemeData theme) => GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.95,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: theme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  IconData _fallbackCategoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('plumb')) return Icons.plumbing_rounded;
    if (n.contains('paint')) return Icons.format_paint_rounded;
    if (n.contains('electric')) return Icons.electrical_services_rounded;
    if (n.contains('carp')) return Icons.handyman_rounded;
    if (n.contains('appliance')) return Icons.kitchen_rounded;
    if (n.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (n.contains('lock')) return Icons.lock_open_rounded;
    if (n.contains('move')) return Icons.local_shipping_rounded;
    if (n.contains('pest')) return Icons.bug_report_rounded;
    return Icons.home_repair_service_rounded;
  }
}

class _CategoryTileItem extends StatelessWidget {
  const _CategoryTileItem({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: theme.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceListingsPreviewGrid extends StatefulWidget {
  @override
  State<_ServiceListingsPreviewGrid> createState() =>
      _ServiceListingsPreviewGridState();
}

class _ServiceListingsPreviewGridState
    extends State<_ServiceListingsPreviewGrid> {
  late Future<List<ServiceListingsRow>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _loadListings();
  }

  Future<List<ServiceListingsRow>> _loadListings() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('service_listings')
          .select()
          .eq('status', 'active')
          .eq('is_available', 'true')
          .order('created_at', ascending: false)
          .limit(10);
      return response.map(ServiceListingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error loading listings: $e',
          tag: 'HomeWidget');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return FutureBuilder<List<ServiceListingsRow>>(
      future: _listingsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildSkeletonList(theme);
        }
        final listings = snapshot.data!;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final listing = listings[index];
            return _ServiceCardItem(
              title: listing.title,
              providerName: listing.providerName ?? 'Provider',
              categoryName: listing.categoryName ?? '',
              price: listing.basePrice,
              rating: listing.rating,
              thumbnail: listing.thumbnail,
              onTap: () {
                context.push('/services/detail?id=${listing.id}');
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonList(AppThemeData theme) => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          width: 150,
          decoration: BoxDecoration(
            color: theme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

class _ServiceCardItem extends StatelessWidget {
  const _ServiceCardItem({
    required this.title,
    required this.providerName,
    required this.categoryName,
    this.price,
    this.rating,
    this.thumbnail,
    required this.onTap,
  });

  final String title;
  final String providerName;
  final String categoryName;
  final double? price;
  final String? rating;
  final String? thumbnail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final ratingValue = double.tryParse(rating ?? '') ?? 0.0;
    return SizedBox(
      width: 150,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    color: theme.surfaceAlt,
                    child: thumbnail != null && thumbnail!.isNotEmpty
                        ? Image.network(
                            thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(theme),
                          )
                        : _buildImagePlaceholder(theme),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        providerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            price != null ? '₱${price!.toStringAsFixed(0)}' : '₱—',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: theme.primary,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.star_rounded, size: 12, color: theme.warning),
                          const SizedBox(width: 2),
                          Text(
                            ratingValue > 0 ? ratingValue.toStringAsFixed(1) : '—',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(AppThemeData theme) => Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: theme.textTertiary,
        ),
      );
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
    final selectedBackgroundAlpha = isEnabled ? 0.08 : 0.04;
    final selectedIconBackgroundAlpha = isEnabled ? 0.12 : 0.06;
    final titleColor =
        isEnabled ? const Color(0xFF16202A) : const Color(0x8016202A);
    final subtitleColor =
        isEnabled ? const Color(0xFF6F7B86) : const Color(0x806F7B86);
    final iconColor = isSelected
        ? theme.primary.withValues(alpha: isEnabled ? 1 : 0.5)
        : isEnabled
            ? const Color(0xFF53606D)
            : const Color(0x8053606D);
    final radioColor = isSelected
        ? theme.primary.withValues(alpha: isEnabled ? 1 : 0.5)
        : isEnabled
            ? const Color(0xFF9AA6B2)
            : const Color(0x809AA6B2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary.withValues(alpha: selectedBackgroundAlpha)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? theme.primary.withValues(alpha: isEnabled ? 1 : 0.5)
                  : const Color(0xFFE5E9EE),
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
                      ? theme.primary
                          .withValues(alpha: selectedIconBackgroundAlpha)
                      : const Color(0xFFF4F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
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
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: subtitleColor,
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
                color: radioColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
