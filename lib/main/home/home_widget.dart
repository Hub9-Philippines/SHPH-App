import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/categoriesgrid/categoriesgrid_widget.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';
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
  late Future<List<ServiceListing>> _recommendedServicesFuture;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, HomeModel.new);
    _loadAddress();
    _loadRecommendedServices();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AddressesRow>>(
        future: _addressFuture,
        builder: (context, snapshot) {
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
          final homeAddressesRow = homeAddressesRowList.isNotEmpty
              ? homeAddressesRowList.first
              : null;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;
                // Only show exit confirmation if there's no page to pop to
                if (!GoRouter.of(context).canPop()) {
                  final shouldExit = await _showExitConfirmation();
                  if (shouldExit && mounted) {
                    SystemNavigator.pop();
                  }
                } else {
                  // Allow normal back navigation
                  if (mounted) {
                    context.pop();
                  }
                }
              },
              child: Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: AppTheme.of(context).primaryBackground,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildHeader(homeAddressesRow),
                            _buildSearchBar(),
                            _buildCategoriesSection(),
                            _buildAdBanner(),
                            _buildRecommendationsSection(),
                            _buildTopServicesSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  /// Load user address with error handling
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
    });
  }

  /// Load recommended services from database
  void _loadRecommendedServices() {
    _recommendedServicesFuture =
        ServiceListingService.instance.fetchRecommendedServices(limit: 10);
  }

  /// Refresh all data when user pulls to refresh
  Future<void> _refreshData() async {
    _loadAddress();
    _loadRecommendedServices();
    await _model.loadNotificationCount();
    safeSetState(() {});
  }

  // ==========================================
  // UI COMPONENTS SEPARATED FOR READABILITY
  // ==========================================

  Widget _buildHeader(AddressesRow? homeAddressesRow) => Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: false,
                    context: context,
                    builder: (context) => GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: const EditAddressWidget(),
                      ),
                    ),
                  ).then((value) => safeSetState(_loadAddress));
                },
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.12,
                      height: MediaQuery.sizeOf(context).width * 0.12,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        maxWidth: 60,
                        minHeight: 40,
                        maxHeight: 60,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EEFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.mapMarkerAlt,
                          color: AppTheme.of(context).primary,
                          size: MediaQuery.sizeOf(context).width * 0.06,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.poppins(),
                                fontSize:
                                    MediaQuery.sizeOf(context).width * 0.03,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                              homeAddressesRow?.addressLine2, 'Home Location'),
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                                fontSize:
                                    MediaQuery.sizeOf(context).width * 0.04,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.bell,
                      color: AppTheme.of(context).primaryText,
                      size: 24,
                    ),
                    onPressed: () =>
                        context.pushNamed(MyNotificationsWidget.routeName),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _model.notificationCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.of(context).primaryBackground,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _model.notificationCount > 99
                                  ? '99+'
                                  : _model.notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
        child: Hero(
          tag: 'searchBarHero',
          child: GestureDetector(
            onTap: () => context.pushNamed(SearchPageWidget.routeName),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.search,
                            color: Color(0x6B14181B), size: 24),
                        const SizedBox(width: 15),
                        Text(
                          'Find service...',
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(),
                                color: const Color(0xE357636C),
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 6,
                      buttonSize: 40,
                      fillColor: const Color(0x2C57636C),
                      icon: const FaIcon(
                        FontAwesomeIcons.slidersH,
                        color: Color(0xE114181B),
                        size: 24,
                      ),
                      onPressed: () => context.pushNamed(
                        SearchPageWidget.routeName,
                        extra: <String, dynamic>{'openFilters': true},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildCategoriesSection() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Services', onSeeAll: () {
              context.pushNamed(
                CategoriesWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': const TransitionInfo(
                    hasTransition: true,
                    transitionType: TransitionType.bottomToTop,
                    duration: Duration(milliseconds: 100),
                  ),
                },
              );
            }),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).width * 0.68,
              child: wrapWithModel(
                model: _model.categoriesgridModel,
                updateCallback: () => safeSetState(() {}),
                child: const CategoriesgridWidget(),
              ),
            ),
          ],
        ),
      );

  Widget _buildAdBanner() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(1, 0, 0, 20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).width * 0.45,
          constraints: const BoxConstraints(
            minHeight: 180,
            maxHeight: 220,
          ),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x4D000000),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset('assets/images/sample-ad-banner.jpg').image,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painting walls services',
                        style: AppTheme.of(context).titleLarge.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800),
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Home painting',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                  FFButtonWidget(
                    onPressed: () => context.pushNamed(
                      ServicesScreen.routeName,
                      extra: {
                        'initialCategory': 'Painting & Decorating',
                        'initialSearch': 'painting',
                      },
                    ),
                    text: 'View More',
                    options: FFButtonOptions(
                      width: 120,
                      height: 42,
                      color: AppTheme.of(context).primaryText,
                      textStyle: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                            color: AppTheme.of(context).primaryBackground,
                            fontSize: 14,
                          ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildRecommendationsSection() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Recommendations', onSeeAll: () {
              context.push('/services?filter=recommended');
            }),
            FutureBuilder<List<ServiceListing>>(
              future: _recommendedServicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).width * 0.8,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: 4,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) => const SizedBox(
                        width: 160,
                        child: ServiceCardSkeleton(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).width * 0.6,
                    child: const Center(
                      child: Text('No recommendations available'),
                    ),
                  );
                }
                final services = snapshot.data!.take(4).toList();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            constraints.maxWidth > 600 ? 0.8 : 0.7,
                      ),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: services.length,
                      itemBuilder: (context, index) =>
                          _buildServiceCard(services[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );

  Widget _buildTopServicesSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Top Service', onSeeAll: () {
            context.push('/services?filter=topRated');
          }),
          FutureBuilder<List<ServiceListing>>(
            future: _recommendedServicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).width * 0.6,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: 5,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) => const SizedBox(
                      width: 160,
                      child: ServiceCardSkeleton(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).width * 0.5,
                  child: const Center(
                    child: Text('No top services available'),
                  ),
                );
              }
              final services = snapshot.data!.take(5).toList();
              return SizedBox(
                height: MediaQuery.sizeOf(context).width * 0.6,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) => SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    child: _buildServiceCard(services[index],
                        imageFit: BoxFit.fill),
                  ),
                ),
              );
            },
          ),
          SizedBox(
              height:
                  MediaQuery.sizeOf(context).width * 0.05), // Bottom padding
        ],
      );
  // ==========================================
  // REUSABLE WIDGETS
  // ==========================================

  Widget _buildSectionTitle(String title, {required VoidCallback onSeeAll}) =>
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    fontSize: 20,
                  ),
            ),
            InkWell(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      color: AppTheme.of(context).primary,
                    ),
              ),
            ),
          ],
        ),
      );

  // This single widget replaces the 9 duplicate containers!
  Widget _buildServiceCard(ServiceListing service,
          {BoxFit imageFit = BoxFit.cover}) =>
      GestureDetector(
        onTap: () {
          print(
              'Navigating to product page with imageUrl: ${service.thumbnail}');
          context.pushNamed(
            ProductPageWidget.routeName,
            extra: <String, dynamic>{
              'serviceName': service.title,
              'category': service.categoryName ?? 'Service',
              'price': service.formattedPrice,
              'rating': service.ratingValue ?? 0.0,
              'reviewCount': service.reviewCount ?? 0,
              'imageUrl': service.thumbnail ?? '',
              'description': service.description ?? '',
              'serviceId': service.id,
              'providerId': service.provider?.toString() ?? '',
              'providerName': service.providerName ?? 'Provider',
              'providerPhoto': service.providerPhoto,
              'providerCategory': service.categoryName ?? 'Service',
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            boxShadow: const [
              BoxShadow(
                  blurRadius: 4, color: Color(0x1A000000), offset: Offset(0, 2))
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).width * 0.35,
                constraints: const BoxConstraints(
                  minHeight: 120,
                  maxHeight: 180,
                ),
                decoration: BoxDecoration(
                  color:
                      service.thumbnail != null && service.thumbnail!.isNotEmpty
                          ? null
                          : AppTheme.of(context).accent1,
                  image:
                      service.thumbnail != null && service.thumbnail!.isNotEmpty
                          ? DecorationImage(
                              fit: imageFit,
                              image: Image.network(service.thumbnail!).image,
                            )
                          : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement favorite toggle with database
                          // Currently just toggles local state for UI feedback
                          final isFavorited =
                              _model.favorites.contains(service.id);
                          if (isFavorited) {
                            _model.favorites.remove(service.id);
                          } else {
                            _model.favorites.add(service.id);
                          }
                          safeSetState(() {});
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _model.favorites.contains(service.id)
                                ? Colors.red
                                : const Color(0x5A14181B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.heart,
                              color: AppTheme.of(context).primaryBackground,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                            fontSize: 15,
                          ),
                    ),
                    Text(
                      service.categoryName ?? 'Service',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.formattedPrice,
                          style: AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                color: AppTheme.of(context).primaryText,
                              ),
                        ),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              service.ratingValue?.toStringAsFixed(1) ?? '0.0',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500),
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${service.reviewCount ?? 0})',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(),
                                    color: AppTheme.of(context).secondaryText,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

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
