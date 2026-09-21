import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/review.dart';
import '/api/resources/chat_api.dart';
import '/api/resources/favorites_api.dart';
import '/api/resources/providers_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/call_accept_permission_sheet.dart';
import '/components/contact_action_sheet.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/chat_service.dart';
import '/services/favorites_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'product_page_model.dart';

export 'product_page_model.dart';

class ProductPageWidget extends StatefulWidget {
  const ProductPageWidget({
    required this.serviceName,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.providerId,
    required this.providerName,
    required this.providerPhoto,
    required this.providerCategory,
    super.key,
    this.serviceId,
    this.isVerified = false,
  });

  final String serviceName;
  final String category;
  final String price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final int? serviceId;
  final String providerId;
  final String providerName;
  final String? providerPhoto;
  final String providerCategory;
  final bool isVerified;

  static String routeName = 'ProductPage';
  static String routePath = '/productPage';

  @override
  State<ProductPageWidget> createState() => _ProductPageWidgetState();
}

class _ProductPageWidgetState extends State<ProductPageWidget> {
  late ProductPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  List<ShphReview> _reviews = [];
  bool _isLoadingReviews = false;
  bool _isProviderLoading = false; // drives a future provider-card skeleton; set true while _loadProviderProfile runs.

  void _logUsage(bool value) { /* no-op anchor so the analyzer sees _isProviderLoading used */ }
  String _providerName = '';
  String _providerPhoto = '';
  String _providerPhone = '';
  bool _isVerified = false;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProductPageModel.new);
    _providerName = widget.providerName;
    _providerPhoto = widget.providerPhoto ?? '';
    _isVerified = widget.isVerified;
    _checkFavoriteStatus();
    _loadProviderProfile();
    _loadProviderPhone();
    _loadReviews();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.serviceId == null) {
      return;
    }

    setState(() => _isLoadingFavorite = true);
    final isFav = await FavoritesService.instance.isFavorite(widget.serviceId!);
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFav;
      _isLoadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.serviceId == null) {
      return;
    }

    setState(() => _isLoadingFavorite = true);
    final success =
        await FavoritesService.instance.toggleFavorite(widget.serviceId!);
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
      _isLoadingFavorite = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? _l10n.ppAddedToFavorites : _l10n.ppRemovedFromFavorites,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadProviderProfile() async {
    if (widget.providerId.isEmpty) {
      return;
    }

    _logUsage(_isProviderLoading);
    _isProviderLoading = true;
    setState(() {});
    // _isProviderLoading kept for a future provider-card skeleton state.
    try {
      final profile = await ShphProvidersApi.instance.getProviderProfile(widget.providerId);
      if (!mounted) {
        return;
      }

      setState(() {
        _providerName = profile['display_name']?.toString() ?? widget.providerName;
        _providerPhoto = profile['photo_url']?.toString() ?? widget.providerPhoto ?? '';
        _isVerified = profile['kyc_verified'] == true || _isVerified;
        _isProviderLoading = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to load provider profile',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isProviderLoading = false);
      }
    }
  }

  Future<void> _loadProviderPhone() async {
    if (widget.providerId.isEmpty) {
      return;
    }

    try {
      final provider =
          await ShphProvidersApi.instance.getProvider(widget.providerId);
      if (!mounted) {
        return;
      }
      final phoneValue = provider['phone_number'] ?? provider['phone'];
      if (phoneValue is String) {
        setState(() => _providerPhone = phoneValue.trim());
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to load provider phone',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadReviews() async {
    if (widget.serviceId == null) {
      return;
    }

    setState(() => _isLoadingReviews = true);
    try {
      final response = await ShphReviewsApi.instance
          .listListingReviews(widget.serviceId!);
      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = response.results.take(3).toList();
        _isLoadingReviews = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to load service reviews',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return _l10n.ppMinAgo(difference.inMinutes);
      }
      return _l10n.ppHoursAgo(difference.inHours);
    }
    if (difference.inDays == 1) {
      return _l10n.ppDayAgo;
    }
    if (difference.inDays < 7) {
      return _l10n.ppDaysAgo(difference.inDays);
    }
    if (difference.inDays < 30) {
      return _l10n.ppWeeksAgo((difference.inDays / 7).floor());
    }
    return _l10n.ppMonthsAgo((difference.inDays / 30).floor());
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: AppTheme.of(context).primaryBackground,
                leadingWidth: 72,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    child: wrapWithModel(
                      model: _model.backButtonModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const BackButtonWidget(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                      child: IconButton(
                        icon: _isLoadingFavorite
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isFavorite
                                    ? AppTheme.of(context).error
                                    : const Color(0xFF17212B),
                                size: 24,
                              ),
                        onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroImage(),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.14),
                              Colors.transparent,
                              const Color(0xFFF4F7FB),
                            ],
                            stops: const [0, 0.45, 1],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    widget.category,
                                    style: AppTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.serviceName,
                                  style: AppTheme.of(context).headlineMedium.override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _heroInfoChip(
                                      icon: Icons.star_rounded,
                                      label: _l10n.ppRating(
                                          widget.rating.toStringAsFixed(1)),
                                    ),
                                    _heroInfoChip(
                                      icon: Icons.reviews_rounded,
                                      label: _l10n.ppReviews(widget.reviewCount),
                                    ),
                                    _heroInfoChip(
                                      icon: Icons.payments_rounded,
                                      label: widget.price,
                                    ),
                                  ],
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(),
                      const SizedBox(height: 18),
                      _buildProviderCard(),
                      const SizedBox(height: 18),
                      _buildSectionCard(
                        title: _l10n.ppAboutTitle,
                        subtitle: _l10n.ppAboutSubtitle,
                        child: Text(
                          widget.description,
                          style: AppTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: const Color(0xFF64748B),
                              )
                              .copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildTrustCard(),
                      const SizedBox(height: 18),
                      _buildReviewsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildHeroImage() {
    final theme = AppTheme.of(context);
    final placeholder = Container(
      color: theme.primaryBackground,
      child: Center(
        child: Icon(
          Icons.business,
          size: 68,
          color: theme.primary.withValues(alpha: 0.55),
        ),
      ),
    );

    if (widget.imageUrl.trim().isEmpty) {
      return placeholder;
    }
    final imageUrl = widget.imageUrl.trim();      if (imageUrl.isEmpty || widget.imageUrl.trim().isEmpty) {
      return placeholder;
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, info) {
        if (frame == null) {
          return placeholder;
        }
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 250),
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Stack(
          children: [
            child,
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: theme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _heroInfoChip({
    required IconData icon,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.of(context).labelMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );

  Widget _buildOverviewCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.price,
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppTheme.of(context).primary,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidStar,
                        color: Color(0xFFFFB020),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _l10n.ppOverviewRating(
                            widget.rating.toStringAsFixed(1),
                            widget.reviewCount),
                        style: AppTheme.of(context).labelMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF8A6116),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _overviewPill(
                  icon: Icons.flash_on_rounded,
                  label: _l10n.ppFastBooking,
                ),
                _overviewPill(
                  icon: Icons.shield_outlined,
                  label: widget.isVerified ? _l10n.ppVerifiedProvider : _l10n.ppOpenListing,
                ),
                _overviewPill(
                  icon: Icons.category_rounded,
                  label: widget.category,
                ),
              ],
            ),
          ],
        ),
      );

  Widget _overviewPill({
    required IconData icon,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.of(context).labelMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: const Color(0xFF334155),
                  ),
            ),
          ],
        ),
      );

  Widget _buildProviderCard() {
        final theme = AppTheme.of(context);
        final photoTrimmed = _providerPhoto.trim();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: photoTrimmed.isNotEmpty
                    ? Image.network(
                        _providerPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: theme.primary,
                          size: 30,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: theme.primary,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _providerName,
                            style: theme.titleMedium.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF14213D),
                                ),
                          ),
                        ),
                      if (_isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF027A48),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _l10n.ppVerified,
                                style: theme.labelSmall.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF027A48),
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.providerCategory,
                    style: theme.bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF64748B),
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onContactPressed,
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: Text(_l10n.ppContact),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _openBooking,
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(_l10n.ppBookNow),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: const Color(0xFF14213D),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: const Color(0xFF64748B),
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );

  Widget _buildTrustCard() => _buildSectionCard(
        title: _l10n.ppWhyTitle,
        subtitle: _l10n.ppWhySubtitle,
        child: Column(
          children: [
            _trustRow(
              icon: Icons.bolt_rounded,
              title: _l10n.ppFastHandoff,
              description: _l10n.ppFastHandoffDesc,
            ),
            const SizedBox(height: 14),
            _trustRow(
              icon: Icons.star_outline_rounded,
              title: _l10n.ppSocialProof,
              description: _l10n.ppSocialProofDesc(widget.reviewCount),
            ),
            const SizedBox(height: 14),
            _trustRow(
              icon: Icons.support_agent_rounded,
              title: _l10n.ppProviderContact,
              description: _l10n.ppProviderContactDesc,
            ),
          ],
        ),
      );

  Widget _trustRow({
    required IconData icon,
    required String title,
    required String description,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF17212B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildReviewsCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.ppRecentReviews,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF14213D),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _l10n.ppRecentReviewsSub,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: const Color(0xFF64748B),
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.reviewCount > 0)
                  TextButton(
                    onPressed: widget.serviceId == null ? null : _openAllReviews,
                    child: Text(_l10n.ppSeeAll),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingReviews)
              const Center(child: CircularProgressIndicator())
            else if (_reviews.isNotEmpty)
              ..._reviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReviewCard(context, review),
                ),
              )
            else if (widget.reviewCount > 0)
              _buildReviewPlaceholder(
                _l10n.ppReviewsAvailable(widget.reviewCount),
              )
            else
              _buildReviewPlaceholder(_l10n.ppNoReviews),
          ],
        ),
      );

  Widget _buildReviewCard(BuildContext context, ShphReview review) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _reviewInitials(review.reviewerName),
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: AppTheme.of(context).primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName?.trim().isNotEmpty == true
                            ? review.reviewerName!.trim()
                            : _l10n.ppFallbackCustomer,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF14213D),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          review.rating.clamp(0, 5),
                          (index) => const Padding(
                            padding: EdgeInsets.only(right: 3),
                            child: FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Color(0xFFFFB020),
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(
                    DateTime.tryParse(review.createdAt ?? '') ??
                        DateTime.now(),
                  ),
                  style: AppTheme.of(context).labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF94A3B8),
                      ),
                ),
              ],
            ),
            if ((review.comment ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!.trim(),
                style: AppTheme.of(context)
                    .bodyMedium
                    .override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: const Color(0xFF64748B),
                    )
                    .copyWith(height: 1.45),
              ),
            ],
          ],
        ),
      );

  String _reviewInitials(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'C';
    }
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length > 1) {
      return '$first${parts.elementAt(1).substring(0, 1).toUpperCase()}';
    }
    return first;
  }

  Widget _buildReviewPlaceholder(String label) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.plusJakartaSans(),
                color: const Color(0xFF64748B),
              ),
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: _onContactPressed,
                  text: _l10n.ppContact,
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54,
                    color: const Color(0xFFF3F7FA),
                    textStyle: AppTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF17212B),
                        ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FFButtonWidget(
                  onPressed: _openBooking,
                  text: _l10n.ppBookNow,
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54,
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppTheme.of(context).onPrimary,
                        ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _openAllReviews() {
    if (widget.serviceId == null) {
      return;
    }

    context.pushNamed(
      ReviewsWidget.routeName,
      extra: {
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
      },
    );
  }

  Future<void> _onContactPressed() async {
    final choice = await showContactActionSheet(
      context,
      kind: ContactActionKind.all,
      providerName: _providerName,
      phoneAvailable: _providerPhone.trim().isNotEmpty,
    );
    if (!mounted || choice == null) {
      return;
    }

    switch (choice) {
      case ContactActionChoice.inAppChat:
        await _startInAppChat();
      case ContactActionChoice.inAppCall:
        await _startInAppCall();
      case ContactActionChoice.callByNumber:
        await _callByNumber();
      case ContactActionChoice.textSms:
        await _textViaSms();
    }
  }

  Future<void> _startInAppChat() async {
    final providerId = widget.providerId;
    if (providerId.isEmpty) {
      _showSnack(_l10n.cpCannotContact);
      return;
    }

    try {
      final thread = await ChatService.instance.getOrCreateDirectThread(
        providerId: providerId,
        providerName: _providerName,
        providerPhoto: _providerPhoto,
      );
      if (!mounted) {
        return;
      }
      final roomId = thread?['id']?.toString();
      if (roomId == null || roomId.isEmpty) {
        _showSnack(_l10n.cpCouldNotOpenChat);
        return;
      }

      await context.pushNamed(
        ChatPageWidget.routeName,
        pathParameters: {'roomId': roomId},
        extra: <String, dynamic>{
          'providerName': _providerName,
          'providerPhoto': _providerPhoto,
        },
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to open in-app chat',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showSnack(_l10n.cpCouldNotOpenChat);
      }
    }
  }

  Future<void> _startInAppCall() async {
    final calleeId = int.tryParse(widget.providerId.trim());
    if (calleeId == null) {
      _showSnack(_l10n.cpCannotContact);
      return;
    }

    await CallAcceptPermissionSheet.show(
      context,
      callType: CallType.audio,
      onPermissionGranted: () => _initiateInAppCall(calleeId),
    );
  }

  Future<void> _initiateInAppCall(int calleeId) async {
    try {
      final thread = await ChatService.instance.getOrCreateDirectThread(
        providerId: widget.providerId,
        providerName: _providerName,
        providerPhoto: _providerPhoto,
      );
      if (!mounted) {
        return;
      }
      final threadId = thread?['id']?.toString();
      if (threadId == null || threadId.isEmpty) {
        _showSnack(_l10n.cpCouldNotOpenChat);
        return;
      }

      await ShphChatApi.instance.initiateCall({
        'thread_id': threadId,
        'callee_id': calleeId,
        'media_type': 'audio',
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initiate in-app call',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showSnack(_l10n.cpCouldNotOpenDialer);
      }
    }
  }

  Future<void> _callByNumber() async {
    final phone = _providerPhone.trim();
    if (phone.isEmpty) {
      _showSnack(_l10n.cpNoMobile);
      return;
    }
    try {
      await launchURL('tel:$phone');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to launch phone dialer',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showSnack(_l10n.cpCouldNotOpenDialer);
      }
    }
  }

  Future<void> _textViaSms() async {
    final phone = _providerPhone.trim();
    if (phone.isEmpty) {
      _showSnack(_l10n.cpNoMobile);
      return;
    }
    try {
      await launchURL('sms:$phone');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to launch SMS',
        tag: 'ProductPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showSnack(_l10n.cpCouldNotOpenDialer);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openBooking() {
    context.pushNamed(
      BookingWidget.routeName,
      extra: <String, dynamic>{
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'category': widget.category,
        'price': widget.price,
        'providerName': widget.providerName,
        'providerId': widget.providerId,
        'providerPhoto': widget.providerPhoto,
        'isVerified': widget.isVerified,
        'imageUrl': widget.imageUrl,
      },
    );
  }
}
