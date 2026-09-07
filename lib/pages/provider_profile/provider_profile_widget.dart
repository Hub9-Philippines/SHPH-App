import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/pages/provider_reviews/provider_reviews_widget.dart';
import '/pages/product_page/product_page_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'provider_profile_model.dart';

export 'provider_profile_model.dart';

class ProviderProfileWidget extends StatefulWidget {
  const ProviderProfileWidget({super.key, required this.providerId});

  final dynamic providerId;

  static String routeName = 'ProviderProfile';
  static String routePath = '/provider/:providerId';

  @override
  State<ProviderProfileWidget> createState() => _ProviderProfileWidgetState();
}

class _ProviderProfileWidgetState extends State<ProviderProfileWidget> {
  late ProviderProfileModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProviderProfileModel.new);
    _model.loadProvider(widget.providerId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.ppfTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : _model.provider == null
              ? _buildError(theme)
              : _buildContent(context, theme),
    );
  }

  Widget _buildError(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_rounded, size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text(_l10n.ppfNotFound,
                style: GoogleFonts.plusJakartaSans(
                    color: theme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme) {
    final p = _model.provider!;
    final name = p['display_name']?.toString() ??
        p['first_name']?.toString() ??
        _l10n.ppfProvider;
    final photo = p['photo_url']?.toString();
    final bio = p['bio']?.toString();
    final rating = _avgRating(p);
    final isKycVerified = p['kyc_verified'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(context, theme, name, photo, bio, isKycVerified),
          const SizedBox(height: 16),
          _buildStats(theme, rating),
          const SizedBox(height: 24),
          _buildSectionHeader(theme, _l10n.ppfServices),
          const SizedBox(height: 12),
          if (_model.listings.isEmpty)
            _buildEmpty(theme, _l10n.ppfNoServices)
          else
            _buildServicesGrid(context, theme),
          const SizedBox(height: 28),
          _buildSectionHeader(theme, _l10n.ppfReviews),
          const SizedBox(height: 12),
          _buildSeeAllReviews(theme),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppThemeData theme, String name,
      String? photo, String? bio, bool verified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
        boxShadow: AppThemeData.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(theme, photo, radius: 38),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.headlineSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                        color: theme.onPrimary,
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(height: 8),
                      _buildVerifiedBadge(theme, compact: true),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (bio != null && bio.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(bio,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.onPrimary.withValues(alpha: 0.82),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(AppThemeData theme, String? photo,
      {required double radius}) {
    final imageUrl = photo?.trim() ?? '';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.onPrimary.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: theme.primaryLight,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty
            ? Icon(Icons.person_rounded, size: radius, color: theme.primary)
            : null,
      ),
    );
  }

  Widget _buildStats(AppThemeData theme, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          _statItem(theme, rating.toStringAsFixed(1), _l10n.ppfRating,
              icon: Icons.star_rounded),
          _statDivider(theme),
          _statItem(theme, _model.provider!['total_completed_bookings']?.toString() ?? '0', _l10n.ppfCompletedBookings,
              icon: Icons.check_circle_outline),
          _statDivider(theme),
          _statItem(theme, _model.listings.length.toString(), _l10n.ppfServices,
              icon: Icons.home_repair_service_outlined),
        ],
      ),
    );
  }

  Widget _statDivider(AppThemeData theme) {
    return Container(width: 1, height: 34, color: theme.border);
  }

  Widget _statItem(AppThemeData theme, String value, String label,
      {required IconData icon}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.primaryBrandText),
          const SizedBox(height: 4),
          Text(value,
              style: theme.titleLarge.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                color: theme.primaryText,
              )),
          const SizedBox(height: 2),
          Text(label, style: theme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge(AppThemeData theme, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: theme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
        border: Border.all(color: theme.onPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              size: compact ? 14 : 16, color: theme.onPrimary),
          const SizedBox(width: 6),
          Text(_l10n.ppfKycVerified,
              style: theme.labelSmall.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
                color: theme.onPrimary,
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              color: theme.primaryText,
            )),
      ],
    );
  }

  Widget _buildEmpty(AppThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, color: theme.textTertiary, size: 28),
          const SizedBox(height: 8),
          Text(message, style: theme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, AppThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _model.listings.map((l) {
          final thumb = l['thumbnail']?.toString() ?? '';
          final price = (l['basePrice'] as num?)?.toDouble();
          final title = l['title'] as String? ?? '';
          final rating = l['rating']?.toString();
          final category = l['categoryName']?.toString();
          final id = l['id'] as int? ?? l['listing_id'] as int? ?? 0;
          return SizedBox(
            width: (constraints.maxWidth - 12) / 2,
            child: GestureDetector(
              onTap: id > 0
                  ? () => context.pushNamed(
                      ProductPageWidget.routeName,
                      extra: <String, dynamic>{
                        'serviceName': title,
                        'category': category ?? '',
                        'price': price != null ? '₱${price.toStringAsFixed(0)}' : '',
                        'rating': rating != null ? double.tryParse(rating) ?? 0.0 : 0.0,
                        'reviewCount': int.parse(l['reviewCount']?.toString() ?? '0'),
                        'imageUrl': thumb,
                        'serviceId': id,
                        'providerId': widget.providerId,
                        'providerName': _model.provider!['display_name']?.toString() ?? _l10n.ppfProvider,
                        'providerPhoto': _model.provider!['photo_url']?.toString(),
                        'providerCategory': category ?? '',
                        'isVerified': _model.provider!['kyc_verified'] == true,
                      },
                    )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
                  border: Border.all(color: theme.border),
                  boxShadow: AppThemeData.shadowSoft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppThemeData.radiusLg),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.55,
                        child: thumb.isNotEmpty
                            ? Image.network(
                                thumb,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildListingPlaceholder(theme),
                              )
                            : _buildListingPlaceholder(theme),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodySmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: theme.primaryText,
                              )),
                          if (category != null && category.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.labelSmall),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (rating != null)
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14, color: AppThemeData.star),
                                    const SizedBox(width: 2),
                                    Text(rating, style: theme.labelSmall),
                                    const SizedBox(width: 6),
                                  ],
                                ),
                              Text(
                                  price != null
                                      ? '₱${price.toStringAsFixed(0)}'
                                      : '',
                                  style: theme.labelMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    color: theme.primary,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListingPlaceholder(AppThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryLight, theme.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.home_repair_service_outlined,
          size: 30,
          color: theme.primary,
        ),
      ),
    );
  }

  Widget _buildSeeAllReviews(AppThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => context.pushNamed(
          ProviderReviewsWidget.routeName,
          pathParameters: <String, String>{'providerId': widget.providerId.toString()},
        ),
        style: TextButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppThemeData.radiusSm)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _l10n.ppfSeeAllReviews,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// Fallback star rating for the hero stat pill when the provider response has no
  /// `avg_rating`. Kept primarily so the stat pill keeps compiling; the profile now
  /// surfaces reviews from the dedicated reviews page.
  double _avgRating(Map<String, dynamic> provider) {
    final avg = _asDouble(provider['avg_rating']);
    if (avg > 0) {
      return avg;
    }
    return 0.0;
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
