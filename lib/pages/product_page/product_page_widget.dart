import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/reviews.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/favorites_service.dart';
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
  List<ReviewsRow> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProductPageModel.new);
    print('ProductPage - imageUrl received: ${widget.imageUrl}');
    _checkFavoriteStatus();
    _loadReviews();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.serviceId == null) {
      return;
    }
    setState(() => _isLoadingFavorite = true);
    final isFav = await FavoritesService.instance.isFavorite(widget.serviceId!);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.serviceId == null) {
      return;
    }
    setState(() => _isLoadingFavorite = true);
    final success =
        await FavoritesService.instance.toggleFavorite(widget.serviceId!);
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadReviews() async {
    if (widget.serviceId == null) {
      return;
    }
    setState(() => _isLoadingReviews = true);
    try {
      final response = await ReviewsTable().queryRows(
        queryFn: (q) => q
            .eq('service_listing_id', widget.serviceId!)
            .order('created_at', ascending: false),
        limit: 3,
      );
      if (mounted) {
        setState(() {
          _reviews = response;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract parameters from navigation after widget tree is built
    final extra =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (extra != null) {
      // Parameters are already set via widget constructor
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildReviewCard(BuildContext context, ReviewsRow review) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.1,
                  height: MediaQuery.sizeOf(context).width * 0.1,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    maxWidth: 48,
                    minHeight: 32,
                    maxHeight: 48,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).accent2,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      review.userId.substring(0, 2).toUpperCase(),
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
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
                        'User',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                      Row(
                        children: List.generate(
                          review.rating,
                          (index) => const FaIcon(
                            FontAwesomeIcons.solidStar,
                            color: Colors.orange,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ],
        ),
      );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
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
              widget.serviceName,
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                child: IconButton(
                  icon: _isLoadingFavorite
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? AppTheme.of(context).error
                              : AppTheme.of(context).primaryText,
                          size: 28,
                        ),
                  onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                ),
              ),
            ],
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).width * 0.6,
                      constraints: const BoxConstraints(
                        minHeight: 250,
                        maxHeight: 400,
                      ),
                      child: widget.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppTheme.of(context).secondaryBackground,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                ),
                              ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  color:
                                      AppTheme.of(context).secondaryBackground,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.of(context).secondaryBackground,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No image available',
                                      style: AppTheme.of(context).bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: MediaQuery.sizeOf(context).width * 0.2,
                        constraints: const BoxConstraints(
                          minHeight: 80,
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.of(context).primaryBackground,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      Text(
                        widget.serviceName,
                        style: AppTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                              fontSize: 24,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.category,
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                                color: AppTheme.of(context).primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price and Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.price,
                              style: AppTheme.of(context).displaySmall.override(
                                    font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold),
                                    color: AppTheme.of(context).primary,
                                    fontSize: 24,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.solidStar,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.rating.toString(),
                                style:
                                    AppTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.reviewCount} reviews)',
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description
                      Text(
                        'Description',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Provider Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navigate to provider profile
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.12,
                                height: MediaQuery.sizeOf(context).width * 0.12,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  maxWidth: 60,
                                  minHeight: 40,
                                  maxHeight: 60,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).accent1,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: widget.providerPhoto != null &&
                                          widget.providerPhoto!.isNotEmpty
                                      ? Image.network(
                                          widget.providerPhoto!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.user,
                                              color: AppTheme.of(context)
                                                  .primaryText,
                                              size: 24,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.user,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...[
                                    Text(
                                      widget.providerName,
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                    ),
                                    ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.providerCategory,
                                        style: AppTheme.of(context)
                                            .bodySmall
                                            .override(
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                            ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                            if (widget.isVerified)
                              FaIcon(
                                FontAwesomeIcons.checkCircle,
                                color: AppTheme.of(context).success,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold),
                                ),
                          ),
                          if (widget.reviewCount > 0)
                            GestureDetector(
                              onTap: () {
                                if (widget.serviceId != null) {
                                  context.pushNamed(
                                    ReviewsWidget.routeName,
                                    extra: {
                                      'serviceId': widget.serviceId,
                                      'serviceName': widget.serviceName,
                                    },
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'See All',
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          color: AppTheme.of(context).primary,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingReviews)
                        const Center(child: CircularProgressIndicator())
                      else if (_reviews.isNotEmpty)
                        ..._reviews.map((review) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReviewCard(context, review),
                            ))
                      else if (widget.reviewCount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.reviewCount} reviews available',
                              style: AppTheme.of(context).bodyMedium.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'No reviews yet',
                              style: AppTheme.of(context).bodyMedium.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ),
                        ),
                      SizedBox(height: MediaQuery.sizeOf(context).width * 0.1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Action Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () {
                        context.pushNamed(
                          ContactProviderWidget.routeName,
                          extra: {
                            'providerName': widget.providerName,
                            'providerId': widget.providerId,
                            'providerPhoto': widget.providerPhoto,
                            'isVerified': widget.isVerified,
                            'mobileNumber':
                                null, // TODO: Add mobile number to product page
                            'serviceName': widget.serviceName,
                            'serviceCategory': widget.category,
                            'servicePrice': widget.price,
                            'serviceDescription': widget.description,
                          },
                        );
                      },
                      text: 'Contact',
                      options: FFButtonOptions(
                        width: double.infinity,
                        color: AppTheme.of(context).secondaryBackground,
                        textStyle: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                              color: AppTheme.of(context).primaryText,
                            ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FFButtonWidget(
                      onPressed: () {
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
                      },
                      text: 'Book Now',
                      icon: const Icon(Icons.calendar_today),
                      options: FFButtonOptions(
                        width: double.infinity,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                              color: AppTheme.of(context).primaryText,
                            ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
