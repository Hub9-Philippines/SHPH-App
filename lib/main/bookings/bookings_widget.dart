import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'bookings_model.dart';

export 'bookings_model.dart';

class BookingsWidget extends StatefulWidget {
  const BookingsWidget({super.key});

  static String routeName = 'Bookings';
  static String routePath = '/bookings';

  @override
  State<BookingsWidget> createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends State<BookingsWidget> {
  late BookingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingsModel.new);
    _model.onStateChanged = () {
      print('onStateChanged callback triggered');
      if (mounted) {
        print('Calling safeSetState');
        safeSetState(() {});
      }
    };
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildBookingCard(BuildContext context, BookingItem booking) {
    // Determine color based on status
    final isCompleted = booking.status.toLowerCase() == 'completed';
    final statusColor =
        isCompleted ? const Color(0xFF797979) : AppTheme.of(context).success;

    return Container(
      width: double.infinity,
      // FIX: Removed the fixed height calculation so the card can grow dynamically
      // height: MediaQuery.sizeOf(context).width * 0.5,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          // FIX: Wrap content tightly instead of trying to stretch to max
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      booking.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // Use Expanded to prevent text overflow horizontally
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.status,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                              color: statusColor,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        booking.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        booking.serviceType,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking date:',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                    Text(
                      booking.date,
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total paid:',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                    Text(
                      '₱${booking.price.toStringAsFixed(0)}', // Format dynamic price
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            FFButtonWidget(
              onPressed: () {
                context.pushNamed(
                  'BookingDetails',
                  extra: <String, dynamic>{
                    'bookingId': booking.id,
                  },
                );
              },
              text: 'View Booking Details',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: const Color(0xFFDFECFF),
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      color: AppTheme.of(context).primary,
                    ),
                elevation: 0,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
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
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Bookings',
                style: AppTheme.of(context).titleLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                      ),
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
              ),
              centerTitle: true,
              expandedTitleScale: 1,
              titlePadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: const BoxDecoration(),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: custom_widgets.CupertinoSlidingWidgetBookings(
                        width: double.infinity,
                        height: double.infinity,
                        initialIndex: _model.selectedTabIndex!,
                        onChanged: (index) async {
                          _model.selectedTabIndex = index;
                          safeSetState(() {});
                          await _model.pageViewController?.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: _model.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppTheme.of(context).error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _model.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context).bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  FFButtonWidget(
                                    onPressed: () => _model.reloadBookings(),
                                    text: 'Retry',
                                    options: FFButtonOptions(
                                      width: 120,
                                      height: 40,
                                      color: AppTheme.of(context).primary,
                                      textStyle: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: AppTheme.of(context)
                                                .primaryText,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _model.isLoading
                            ? ListView.separated(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  left: 15,
                                  right: 15,
                                  bottom:
                                      MediaQuery.sizeOf(context).width * 0.1,
                                ),
                                itemCount: 3,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) =>
                                    const BookingCardSkeleton(),
                              )
                            : PageView(
                                controller: _model.pageViewController ??=
                                    PageController(
                                        initialPage: max(
                                            0,
                                            min(
                                                valueOrDefault<int>(
                                                    _model.selectedTabIndex, 0),
                                                1))),
                                onPageChanged: (_) async {
                                  safeSetState(() {});
                                  _model.selectedTabIndex =
                                      _model.pageViewCurrentIndex;
                                  safeSetState(() {});
                                },
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // --- PAGE 1: IN PROGRESS ---
                                  if (_model.inProgressList.isEmpty) Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.inbox,
                                                size: 64,
                                                color: AppTheme.of(context)
                                                    .secondaryText,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No bookings in progress',
                                                style: AppTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color:
                                                          AppTheme.of(context)
                                                              .secondaryText,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ) else ListView.separated(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            left: 15,
                                            right: 15,
                                            bottom: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.1,
                                          ),
                                          itemCount:
                                              _model.inProgressList.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) =>
                                              _buildBookingCard(context,
                                                  _model.inProgressList[index]),
                                        ),
                                  // --- PAGE 2: COMPLETED ---
                                  if (_model.completedList.isEmpty) Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.inbox,
                                                size: 64,
                                                color: AppTheme.of(context)
                                                    .secondaryText,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No completed bookings',
                                                style: AppTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      color:
                                                          AppTheme.of(context)
                                                              .secondaryText,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ) else ListView.separated(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            left: 15,
                                            right: 15,
                                            bottom: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.1,
                                          ),
                                          itemCount:
                                              _model.completedList.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            final item =
                                                _model.completedList[index];
                                            return _buildBookingCard(
                                                context, item);
                                          },
                                        ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
