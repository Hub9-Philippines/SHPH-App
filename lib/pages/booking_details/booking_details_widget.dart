import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/bookings.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/booking_step_indicator.dart';
import '/components/star_rating.dart';
import '/components/user_avatar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/booking_funnel/status_page.dart';
import '/services/bookings_service.dart';
import '/theme/app_theme.dart';
import 'booking_details_model.dart';

export 'booking_details_model.dart';

class BookingDetailsWidget extends StatefulWidget {
  const BookingDetailsWidget({
    super.key,
    this.bookingId,
  });

  final String? bookingId;

  static String routeName = 'BookingDetails';
  static String routePath = '/booking-details';

  @override
  State<BookingDetailsWidget> createState() => _BookingDetailsWidgetState();
}

class _BookingDetailsWidgetState extends State<BookingDetailsWidget> {
  late BookingDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingDetailsModel.new);
    _loadBookingDetails();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails() async {
    if (widget.bookingId == null) {
      setState(() => _model.errorMessage = 'Booking ID is required');
      return;
    }

    setState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      final booking =
          await BookingsService.instance.getBookingById(widget.bookingId!);

      if (booking != null) {
        Map<String, dynamic>? service;
        final parsedId =
            int.tryParse(booking.serviceListingId.toString());
        if (parsedId != null) {
          try {
            final listing =
                await ShphServicesApi.instance.getListing(parsedId);
            service = {
              'id': listing.id,
              'title': listing.title,
              'description': listing.description,
              'base_price': listing.basePrice,
              'category_name': listing.categoryName,
              'thumbnail': listing.thumbnail,
              'provider_name': listing.providerName,
              'provider_photo': listing.providerPhoto,
              'provider_id': listing.provider?.toString(),
              'rating': listing.rating,
            };
          } catch (_) {}
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _model.booking = booking;
          _model.serviceListing = service;
          _model.isLoading = false;
        });
      } else {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Booking not found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Failed to load booking: $e';
        });
      }
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content:
            const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && _model.booking != null) {
      final success =
          await BookingsService.instance.cancelBooking(_model.booking!.id);
      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppThemeData.successTeal,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel booking'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  bool get _isTrackable {
    final status = _model.booking?.status.toLowerCase() ?? '';
    return status == 'pending' ||
        status == 'confirmed' ||
        status == 'in_progress' ||
        status == 'en_route';
  }

  bool get _isCancellable {
    final status = _model.booking?.status.toLowerCase() ?? '';
    return status == 'pending' || status == 'confirmed';
  }

  void _openContact({
    required BuildContext context,
  }) {
    final listing = _model.serviceListing;
    context.pushNamed(
      ContactProviderWidget.routeName,
      extra: <String, dynamic>{
        'providerName':
            listing?['provider_name'] as String? ?? 'Assigned Provider',
        'providerId': listing?['provider_id'] as String?,
        'providerPhoto': listing?['provider_photo'] as String?,
        'isVerified': false,
      },
    );
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatusPage(
          bookingStatus: _model.booking!.status,
          bookingDate: _model.booking!.bookingDate,
          providerName: _providerName,
          serviceTitle:
              _model.serviceListing?['title'] as String? ?? 'Your booking',
          bookingReference: _model.booking!.id,
        ),
      ),
    );
  }

  String get _providerName =>
      _model.serviceListing?['provider_name'] as String? ?? 'Assigned Provider';

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          bottomNavigationBar: _model.isLoading || _model.booking == null
              ? null
              : _buildStickyFooter(context),
          body: SafeArea(
            child: _model.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.of(context).primary,
                    ),
                  )
                : _model.errorMessage != null
                    ? _buildMessageState(
                        context,
                        icon: Icons.error_outline_rounded,
                        title: 'Could not load booking',
                        subtitle: _model.errorMessage!,
                        actionLabel: 'Retry',
                        onPressed: _loadBookingDetails,
                        iconColor: AppTheme.of(context).error,
                      )
                    : _model.booking == null
                        ? _buildMessageState(
                            context,
                            icon: Icons.inventory_2_outlined,
                            title: 'No booking data',
                            subtitle:
                                'This booking could not be found or is no longer available.',
                            actionLabel: 'Go back',
                            onPressed: () => Navigator.of(context).maybePop(),
                            iconColor: AppTheme.of(context).secondaryText,
                          )
                        : RefreshIndicator(
                            color: AppTheme.of(context).primary,
                            onRefresh: _loadBookingDetails,
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 28),
                              children: [
                                _buildTopBar(context),
                                const SizedBox(height: 18),
                                _buildProviderSummaryCard(context),
                                const SizedBox(height: 18),
                                _buildProgressCard(context),
                                const SizedBox(height: 18),
                                _buildInfoSection(context),
                                if (_model.booking!.notes != null &&
                                    _model.booking!.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  _buildSectionCard(
                                    context,
                                    title: 'Notes',
                                    subtitle:
                                        'Special instructions attached to this booking.',
                                    child: Text(
                                      _model.booking!.notes!,
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font:
                                                GoogleFonts.plusJakartaSans(),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
          ),
        ),
      );

  /// Zone 1 — assigned professional summary with floating call/message
  /// circular actions.
  Widget _buildProviderSummaryCard(BuildContext context) {
    final theme = AppTheme.of(context);
    final rating =
        (_model.serviceListing?['rating'] as num?)?.toDouble() ?? 0.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
            boxShadow: AppThemeData.shadowSoft,
          ),
          child: Row(
            children: [
              UserAvatar(
                photoUrl: _model.serviceListing?['provider_photo'] as String?,
                name: _providerName,
                size: 56,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall.override(
                        font:
                            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StarRating(rating: rating, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : 'New',
                          style: theme.labelSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _model.serviceListing?['title'] as String? ??
                          'Service professional',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: theme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -14,
          right: 12,
          child: Row(
            children: [
              _FloatingCircleButton(
                icon: Icons.call_rounded,
                tooltip: 'Call provider',
                onTap: () => _openContact(context: context),
              ),
              const SizedBox(width: 8),
              _FloatingCircleButton(
                icon: Icons.chat_bubble_rounded,
                tooltip: 'Message provider',
                onTap: () => _openContact(context: context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Zone 2 — vertical progress timeline derived from server status and
  /// timestamps.
  Widget _buildProgressCard(BuildContext context) {
    final theme = AppTheme.of(context);
    final booking = _model.booking!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
        boxShadow: AppThemeData.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Service progress',
                  style: theme.titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: theme.primaryText,
                  ),
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 14),
          BookingStepIndicator(
            steps: _progressSteps(booking),
            currentStep: _currentProgressStep(booking.status),
          ),
          if (booking.status.toLowerCase() == 'cancelled') ...[
            const SizedBox(height: 10),
            Text(
              'This booking was cancelled.',
              style: theme.bodySmall.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
                color: AppThemeData.destructiveSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<BookingStep> _progressSteps(BookingsRow booking) {
    String? fmt(String? iso) {
      final dt = DateTime.tryParse(iso ?? '');
      if (dt == null) {
        return null;
      }
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final suffix = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month} · $hour:$minute $suffix';
    }

    return [
      BookingStep(
        label: 'Booking placed',
        icon: Icons.receipt_long_rounded,
        timestamp: fmt(_rowField('created_at') ?? booking.createdAt.toString()),
      ),
      const BookingStep(
        label: 'Provider confirmed',
        icon: Icons.verified_rounded,
      ),
      BookingStep(
        label: 'Arrived on site',
        icon: Icons.directions_walk_rounded,
        timestamp: fmt(_rowField('arrived_at')),
      ),
      BookingStep(
        label: 'Service in progress',
        icon: Icons.construction_rounded,
        timestamp: fmt(_rowField('started_at')),
      ),
      const BookingStep(
        label: 'Completed',
        icon: Icons.task_alt_rounded,
      ),
    ];
  }

  String? _rowField(String key) =>
      _model.booking != null && _model.booking!.data.containsKey(key)
          ? _model.booking!.data[key].toString()
          : null;

  int _currentProgressStep(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return 1;
      case 'confirmed':
      case 'accepted':
        return 1;
      case 'arrived':
      case 'en_route':
        return 2;
      case 'in_progress':
      case 'in progress':
        return 3;
      case 'completed':
        return 4;
      default:
        // Unknown statuses fall back safely to the first stage.
        return 1;
    }
  }

  Widget _buildInfoSection(BuildContext context) {
    final booking = _model.booking!;
    return _buildSectionCard(
      context,
      title: 'Booking information',
      subtitle: 'Core scheduling, payment, and location details.',
      child: Column(
        children: [
          _buildInfoRow(context, 'Booking ID', booking.id.substring(0, 8)),
          _buildInfoRow(
            context,
            'Date & Time',
            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} · ${booking.bookingTime}',
          ),
          _buildInfoRow(context, 'Status', _formatStatus(booking.status)),
          _buildInfoRow(
            context,
            'Payment status',
            booking.paymentStatus ?? 'Pending',
          ),
          _buildInfoRow(context, 'Service location', _serviceLocationLine()),
        ],
      ),
    );
  }

  /// Server-derived address first; falls back to the notes text the funnel
  /// embeds ('Address: <line>, <city>').
  String _serviceLocationLine() {
    final fromServer = _rowField('client_address');
    if (fromServer != null && fromServer.trim().isNotEmpty) {
      return fromServer.trim();
    }
    final notes = _model.booking?.notes ?? '';
    final match = RegExp(r'Address:\s*([^|]+)').firstMatch(notes);
    if (match != null) {
      final value = match.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return 'Shared with your provider after assignment';
  }

  Widget _buildTopBar(BuildContext context) => Row(
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
                  'Booking Details',
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                Text(
                  'Review progress, schedule, and payment state.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ],
      );

  /// Zone 3 — sticky footer with map CTA and destructive cancel link.
  Widget _buildStickyFooter(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.border)),
        boxShadow: AppThemeData.shadowSoft,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: (_isTrackable && _model.booking != null)
                    ? _openMap
                    : null,
                icon: const Icon(Icons.map_rounded, size: 20),
                label: Text(
                  'Track on Map',
                  style: theme.titleSmall.override(
                    font:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppThemeData.actionPrimary,
                  disabledBackgroundColor:
                      AppThemeData.actionPrimary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                  ),
                ),
              ),
            ),
            if (_isCancellable)
              TextButton.icon(
                onPressed: _cancelBooking,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  'Cancel Booking',
                  style: theme.labelLarge.override(
                    font:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppThemeData.destructiveSoft,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.destructiveSoft,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          border: Border.all(color: AppTheme.of(context).border),
          boxShadow: AppThemeData.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _buildInfoRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
            ),
          ],
        ),
      );

  String _formatStatus(String? status) {
    if (status == null) {
      return 'Unknown';
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onPressed,
    required Color iconColor,
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
              borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
              boxShadow: AppThemeData.shadowSoft,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.of(context).primary,
                    foregroundColor: AppTheme.of(context).onPrimary,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) =
        AppThemeData.statusColors(status.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      ),
      child: Text(
        status,
        style: AppTheme.of(context).labelSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              color: textColor,
            ),
      ),
    );
  }
}

class _FloatingCircleButton extends StatelessWidget {
  const _FloatingCircleButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: AppThemeData.actionPrimary,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 19, color: Colors.white),
            ),
          ),
        ),
      );
}
