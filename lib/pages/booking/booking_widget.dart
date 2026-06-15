import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/addresses.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'booking_model.dart';

export 'booking_model.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({
    super.key,
    this.serviceName,
    this.category,
    this.price,
    this.imageUrl,
    this.serviceId,
  });

  final String? serviceName;
  final String? category;
  final String? price;
  final String? imageUrl;
  final int? serviceId;

  static String routeName = 'Booking';
  static String routePath = '/booking';

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  late BookingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingModel.new);
  }

  Future<void> _proceedToPayment() async {
    if (widget.serviceId == null) {
      setState(() => _model.errorMessage = 'Service ID is required');
      return;
    }

    if (_model.selectedDate == null) {
      setState(() => _model.errorMessage = 'Please select a date');
      return;
    }

    if (_model.selectedTime == null) {
      setState(() => _model.errorMessage = 'Please select a time');
      return;
    }

    if (_model.selectedAddress == null) {
      setState(() => _model.errorMessage = 'Please select an address');
      return;
    }

    setState(() {
      _model.errorMessage = null;
    });

    // Navigate to payment screen with booking payload
    if (mounted) {
      await context.pushNamed(
        'BookingPayment',
        extra: <String, dynamic>{
          'serviceId': widget.serviceId,
          'serviceName': widget.serviceName,
          'category': widget.category,
          'price': widget.price,
          'imageUrl': widget.imageUrl,
          'bookingDate': _model.selectedDate!.toIso8601String(),
          'bookingTime': _model.selectedTime!.format(context),
          'notes': _model.notesController.text.isNotEmpty
              ? _model.notesController.text
              : null,
          'addressId': _model.selectedAddress?.id,
          'address': _model.selectedAddress,
        },
      );
    }
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
              'Book Service',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Summary
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Container(
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.imageUrl != null
                              ? Image.network(
                                  widget.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 80,
                                    height: 80,
                                    color: AppTheme.of(context).secondaryText,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: AppTheme.of(context).secondaryText,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color:
                                        AppTheme.of(context).primaryBackground,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.serviceName ?? 'Service',
                                style:
                                    AppTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.category ?? 'Category',
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.price ?? '₱0',
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).primary,
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
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
                // Date Selection
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (selectedDate != null) {
                            safeSetState(() {
                              _model.selectedDate = selectedDate;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
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
                              Icon(
                                Icons.calendar_today,
                                color: AppTheme.of(context).primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _model.selectedDate != null
                                      ? '${_model.selectedDate!.day}/${_model.selectedDate!.month}/${_model.selectedDate!.year}'
                                      : 'Select a date',
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color: _model.selectedDate != null
                                            ? AppTheme.of(context).primaryText
                                            : AppTheme.of(context)
                                                .secondaryText,
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.of(context).secondaryText,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Time Selection
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Time',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            safeSetState(() {
                              _model.selectedTime = selectedTime;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
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
                              Icon(
                                Icons.access_time,
                                color: AppTheme.of(context).primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _model.selectedTime != null
                                      ? _model.selectedTime!.format(context)
                                      : 'Select a time',
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color: _model.selectedTime != null
                                            ? AppTheme.of(context).primaryText
                                            : AppTheme.of(context)
                                                .secondaryText,
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.of(context).secondaryText,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Address Selection
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Address',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final selectedAddress = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const EditAddressWidget(),
                          );
                          if (selectedAddress != null &&
                              selectedAddress is AddressesRow) {
                            setState(() {
                              _model.selectedAddress = selectedAddress;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _model.selectedAddress != null
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).alternate,
                              width: _model.selectedAddress != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: _model.selectedAddress != null
                                    ? AppTheme.of(context).primary
                                    : AppTheme.of(context).secondaryText,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _model.selectedAddress != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _model.selectedAddress!
                                                    .addressLine2 ??
                                                'Address',
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_model.selectedAddress!.addressLine1 ?? ''}, ${_model.selectedAddress!.city ?? ''}',
                                            style: AppTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  color: AppTheme.of(context)
                                                      .secondaryText,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Select service address',
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                            ),
                                      ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.of(context).secondaryText,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes (Optional)',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _model.notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add any special instructions...',
                          hintStyle: AppTheme.of(context).bodySmall,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).alternate,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.of(context).secondaryBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).width * 0.1),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_model.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _model.errorMessage!,
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).error,
                            ),
                      ),
                    ),
                  FFButtonWidget(
                    onPressed: _proceedToPayment,
                    text: 'Proceed to Payment',
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
                ],
              ),
            ),
          ),
        ),
      );
}
