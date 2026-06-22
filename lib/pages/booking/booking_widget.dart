import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/addresses.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
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

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (selectedDate != null) {
      safeSetState(() {
        _model.selectedDate = selectedDate;
        _model.errorMessage = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      safeSetState(() {
        _model.selectedTime = selectedTime;
        _model.errorMessage = null;
      });
    }
  }

  Future<void> _pickAddress() async {
    final selectedAddress = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditAddressWidget(),
    );
    if (selectedAddress != null && selectedAddress is AddressesRow) {
      safeSetState(() {
        _model.selectedAddress = selectedAddress;
        _model.errorMessage = null;
      });
    }
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

    if (!mounted) {
      return;
    }

    await context.pushNamed(
      BookingPaymentWidget.routeName,
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
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
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
                                'Book Service',
                                style: AppTheme.of(context).titleLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF14213D),
                                    ),
                              ),
                              Text(
                                'Choose your schedule and location before payment.',
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.poppins(),
                                      color: const Color(0xFF64748B),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 18),
                      _buildStepCard(
                        step: '1',
                        title: 'Select Date',
                        subtitle: 'Pick the day you want the provider to arrive.',
                        child: _buildActionTile(
                          icon: Icons.calendar_today_rounded,
                          label: _model.selectedDate != null
                              ? _formatDate(_model.selectedDate!)
                              : 'Select a date',
                          isSelected: _model.selectedDate != null,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildStepCard(
                        step: '2',
                        title: 'Select Time',
                        subtitle: 'Choose your preferred appointment window.',
                        child: _buildActionTile(
                          icon: Icons.access_time_rounded,
                          label: _model.selectedTime != null
                              ? _model.selectedTime!.format(context)
                              : 'Select a time',
                          isSelected: _model.selectedTime != null,
                          onTap: _pickTime,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildStepCard(
                        step: '3',
                        title: 'Service Address',
                        subtitle: 'Tell the provider exactly where the work happens.',
                        child: _buildActionTile(
                          icon: Icons.location_on_rounded,
                          label: _selectedAddressTitle,
                          detail: _selectedAddressSubtitle,
                          isSelected: _model.selectedAddress != null,
                          onTap: _pickAddress,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildStepCard(
                        step: '4',
                        title: 'Additional Notes',
                        subtitle:
                            'Share instructions, landmarks, or preparation details.',
                        child: TextFormField(
                          controller: _model.notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Add any special instructions...',
                            hintStyle: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.poppins(),
                                  color: const Color(0xFF94A3B8),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).primary,
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildHeroCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F8A6C),
              Color(0xFF18B38C),
              Color(0xFF7AD9B9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220F8A6C),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _buildServiceImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.category ?? 'Service',
                      style: AppTheme.of(context).labelMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.serviceName ?? 'Service',
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price ?? 'PHP 0',
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildServiceImage() {
    if ((widget.imageUrl ?? '').trim().isEmpty) {
      return Container(
        width: 96,
        height: 96,
        color: Colors.white.withValues(alpha: 0.18),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 34,
        ),
      );
    }

    return Image.network(
      widget.imageUrl!,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 96,
        height: 96,
        color: Colors.white.withValues(alpha: 0.18),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: AppTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(
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
                        title,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF14213D),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(),
                              color: const Color(0xFF64748B),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
    String? detail,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FBF7) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.of(context).primary.withValues(alpha: 0.32)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.of(context).primary.withValues(alpha: 0.14)
                        : const Color(0xFFEFF4F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.of(context).primary
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: isSelected
                                  ? const Color(0xFF14213D)
                                  : const Color(0xFF64748B),
                            ),
                      ),
                      if (detail != null && detail.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.poppins(),
                                color: const Color(0xFF64748B),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppTheme.of(context).primary
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_model.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _model.errorMessage!,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          color: AppTheme.of(context).error,
                        ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.poppins(),
                                color: const Color(0xFF64748B),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.price ?? 'PHP 0',
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: AppTheme.of(context).primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FFButtonWidget(
                      onPressed: _proceedToPayment,
                      text: 'Proceed to Payment',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  String _formatDate(DateTime value) {
    final monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month - 1]} ${value.day}, ${value.year}';
  }

  String get _selectedAddressTitle {
    if (_model.selectedAddress == null) {
      return 'Select service address';
    }

    return _model.selectedAddress!.addressLine2?.trim().isNotEmpty == true
        ? _model.selectedAddress!.addressLine2!.trim()
        : 'Selected address';
  }

  String? get _selectedAddressSubtitle {
    if (_model.selectedAddress == null) {
      return null;
    }

    final line1 = _model.selectedAddress!.addressLine1 ?? '';
    final city = _model.selectedAddress!.city ?? '';
    final composed = [line1, city]
        .where((part) => part.trim().isNotEmpty)
        .join(', ')
        .trim();
    return composed.isEmpty ? null : composed;
  }
}
