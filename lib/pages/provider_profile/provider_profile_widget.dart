import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Provider Profile', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
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
            Icon(Icons.person_off_rounded,
                size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text('Provider not found',
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
        'Provider';
    final photo = p['photo_url']?.toString() ?? p['photo']?.toString();
    final bio = p['bio_details']?.toString() ?? p['bio']?.toString();
    final rating = _avgRating();
    final isKycVerified = p['verification_status']?.toString() == 'verified';

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHero(context, theme, name, photo, bio, rating, isKycVerified),
          _buildStats(theme, rating),
          if (isKycVerified) _buildVerifiedBadge(theme),
          _buildSectionHeader(theme, 'Services'),
          if (_model.listings.isEmpty)
            _buildEmpty(theme, 'No services posted yet.')
          else
            _buildServicesGrid(context, theme),
          _buildSectionHeader(theme, 'Reviews'),
          if (_model.reviews.isEmpty)
            _buildEmpty(theme, 'No reviews yet.')
          else
            _buildReviewsList(theme),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppThemeData theme, String name,
      String? photo, String? bio, double rating, bool verified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                photo != null ? NetworkImage(photo) : null,
            child: photo == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(name,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          if (bio != null && bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(bio,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(AppThemeData theme, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _statItem(theme, rating.toStringAsFixed(1), 'Rating'),
          _statItem(theme, _model.reviews.length.toString(), 'Reviews'),
          _statItem(theme, _model.listings.length.toString(), 'Services'),
        ],
      ),
    );
  }

  Widget _statItem(AppThemeData theme, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  color: theme.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: theme.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge(AppThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: 16, color: theme.success),
            const SizedBox(width: 6),
            Text('KYC Verified',
                style: GoogleFonts.plusJakartaSans(
                    color: theme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty(AppThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(message,
          style: GoogleFonts.plusJakartaSans(
              color: theme.secondaryText, fontSize: 14)),
    );
  }

  Widget _buildServicesGrid(BuildContext context, AppThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _model.listings.map((l) {
          final thumb = l['thumbnail'] as String?;
          final price = l['basePrice'] as double?;
          final title = l['title'] as String? ?? '';
          final rating = l['rating'] as String?;
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 60) / 2,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: thumb != null
                          ? Image.network(thumb,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : Container(
                              height: 100,
                              color: theme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.image_rounded,
                                  color: theme.primary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  color: theme.primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (rating != null)
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14, color: theme.warning),
                                    const SizedBox(width: 2),
                                    Text(rating,
                                        style: GoogleFonts.plusJakartaSans(
                                            color: theme.secondaryText,
                                            fontSize: 11)),
                                    const SizedBox(width: 6),
                                  ],
                                ),
                              Text(
                                  price != null
                                      ? '₱${price.toStringAsFixed(0)}'
                                      : '',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: theme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
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

  Widget _buildReviewsList(AppThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _model.reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = _model.reviews[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: r['reviewerPhoto'] != null
                    ? NetworkImage(r['reviewerPhoto'] as String)
                    : null,
                child: r['reviewerPhoto'] == null
                    ? Icon(Icons.person, color: theme.secondaryText)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['reviewerName']?.toString() ?? 'Anonymous',
                        style: GoogleFonts.plusJakartaSans(
                            color: theme.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14, color: theme.warning),
                        const SizedBox(width: 4),
                        Text(
                            (r['rating'] as num?)?.toStringAsFixed(1) ?? '',
                            style: GoogleFonts.plusJakartaSans(
                                color: theme.secondaryText, fontSize: 12)),
                      ],
                    ),
                    if (r['comment'] != null) ...[
                      const SizedBox(height: 4),
                      Text(r['comment'] as String,
                          style: GoogleFonts.plusJakartaSans(
                              color: theme.primaryText, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _avgRating() {
    if (_model.reviews.isEmpty) return 0.0;
    final sum =
        _model.reviews.fold<num>(0, (a, r) => a + (r['rating'] as num? ?? 0));
    return sum / _model.reviews.length;
  }
}
