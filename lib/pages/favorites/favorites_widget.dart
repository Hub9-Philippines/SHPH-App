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
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Favorites',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: FutureBuilder<List<ServiceListingsRow>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading favorites',
                    style: AppTheme.of(context).bodyMedium,
                  ),
                );
              }

              final favorites = snapshot.data ?? [];

              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: AppTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save services you love',
                        style: AppTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshFavorites,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final service = favorites[index];
                    return _buildServiceCard(service);
                  },
                ),
              );
            },
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    service.thumbnail ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.of(context).secondaryText,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppTheme.of(context).primaryBackground,
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
                        service.title,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.categoryName ?? 'Service',
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _parseRating(service.rating).toStringAsFixed(1),
                            style: AppTheme.of(context).bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${service.reviewCount ?? 0})',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatPrice(service.basePrice, service.priceUnit),
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).primary,
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
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

  String _formatPrice(double? price, String? unit) {
    if (price == null) return '₱0';
    return '₱${price.toStringAsFixed(0)}${unit != null ? ' / $unit' : ''}';
  }

  double _parseRating(String? rating) {
    if (rating == null) return 0;
    return double.tryParse(rating) ?? 0.0;
  }
}
