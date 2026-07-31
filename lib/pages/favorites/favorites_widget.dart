import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/favorites_service.dart';
import '/theme/app_theme.dart';
import 'favorites_model.dart';

export 'favorites_model.dart';

class FavoritesWidget extends StatefulWidget {
  const FavoritesWidget({super.key});

  static String routeName = 'Favorites';
  static String routePath = '/favorites';

  @override
  State<FavoritesWidget> createState() => _FavoritesWidgetState();
}

class _FavoritesWidgetState extends State<FavoritesWidget> {
  late FavoritesModel _model;
  late Future<List<ServiceListingsRow>> _favoritesFuture;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, FavoritesModel.new);
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoritesFuture = FavoritesService.instance.getFavoriteServices();
  }

  Future<void> _refreshFavorites() async {
    _loadFavorites();
    safeSetState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: AppTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorites',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: AppTheme.of(context).primaryText,
                                  ),
                            ),
                            Text(
                              'Quick access to the services you want to revisit.',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<ServiceListingsRow>>(
                    future: _favoritesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return _buildMessageState(
                          context,
                          icon: Icons.error_outline_rounded,
                          title: 'Error loading favorites',
                          subtitle:
                              'Something went wrong while loading your saved services.',
                        );
                      }

                      final favorites = snapshot.data ?? [];
                      if (favorites.isEmpty) {
                        return _buildMessageState(
                          context,
                          icon: Icons.favorite_border_rounded,
                          title: 'No favorites yet',
                          subtitle:
                              'Save the services you love so they are easy to book again.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshFavorites,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildServiceCard(favorites[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppThemeData.shadowSoft,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 30, color: AppTheme.of(context).primary),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildServiceCard(ServiceListingsRow service) => GestureDetector(
        onTap: () => context.pushNamed(
          ProductPageWidget.routeName,
          extra: <String, dynamic>{
            'serviceId': service.id,
            'serviceName': service.title,
            'category': service.categoryName ?? 'Service',
            'price': _formatPrice(service.basePrice, service.priceUnit),
            'rating': _parseRating(service.rating),
            'reviewCount': service.reviewCount ?? 0,
            'imageUrl': service.thumbnail ?? '',
            'description': service.description ?? '',
            'providerId': service.provider?.toString() ?? '',
            'providerName': service.providerName ?? 'Provider',
            'providerPhoto': service.providerPhoto,
            'providerCategory': service.categoryName ?? 'Service',
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: (service.thumbnail ?? '').trim().isNotEmpty
                      ? Image.network(
                          service.thumbnail!,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(context),
                        )
                      : _imageFallback(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: AppTheme.of(context).primaryText,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.categoryName ?? 'Service',
                          style: AppTheme.of(context).labelSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: AppTheme.of(context).primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFB020),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _parseRating(service.rating).toStringAsFixed(1),
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${service.reviewCount ?? 0})',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatPrice(service.basePrice, service.priceUnit),
                        style: AppTheme.of(context).titleSmall.override(
                              color: AppTheme.of(context).primary,
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
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
      );

  Widget _imageFallback(BuildContext context) => Container(
        width: 88,
        height: 88,
        color: const Color(0xFFE7ECF1),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.of(context).secondaryText,
        ),
      );

  String _formatPrice(double? price, String? unit) {
    if (price == null) {
      return 'PHP 0';
    }
    return 'PHP ${price.toStringAsFixed(0)}${unit != null ? ' / $unit' : ''}';
  }

  double _parseRating(String? rating) {
    if (rating == null) {
      return 0;
    }
    return double.tryParse(rating) ?? 0.0;
  }
}
