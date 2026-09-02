import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/screen_header.dart';
import '/components/soft_card.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class OnDemandBookingWidget extends StatefulWidget {
  const OnDemandBookingWidget({super.key});

  static String routeName = 'OnDemandBooking';
  static String routePath = '/on-demand-booking';

  @override
  State<OnDemandBookingWidget> createState() => _OnDemandBookingWidgetState();
}

class _OnDemandBookingWidgetState extends State<OnDemandBookingWidget> {
  int _urgencyDays = 0;
  String? _selectedTimeSlot;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  final timeSlots = [
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.secondaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
                title: _l10n.obTitle, subtitle: _l10n.obSubtitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildUrgencySelector(context),
                  const SizedBox(height: 20),
                  _buildTimeSlots(context),
                  const SizedBox(height: 20),
                  _buildBookingInfo(context),
                  const SizedBox(height: 24),
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencySelector(BuildContext context) {
    final theme = AppTheme.of(context);
    final options = [
      _l10n.obOptionNow,
      _l10n.obOptionToday,
      _l10n.obOptionTomorrow,
      _l10n.obOptionThisWeek,
    ];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.obWhenNeed,
              style: theme.titleSmall.override(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.asMap().entries.map((e) {
              final i = e.key;
              final label = e.value;
              final selected = _urgencyDays == i;
              return GestureDetector(
                onTap: () => setState(() => _urgencyDays = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? theme.primary : theme.primaryBackground,
                    borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
                    border: Border.all(
                      color: selected ? theme.primary : theme.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: selected ? Colors.white : theme.primaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    final theme = AppTheme.of(context);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.obPreferredTime,
              style: theme.titleSmall.override(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              )),
          const SizedBox(height: 12),
          ...timeSlots.map((slot) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTimeSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTimeSlot == slot
                          ? theme.primary.withValues(alpha: 0.08)
                          : theme.primaryBackground,
                      borderRadius: BorderRadius.circular(AppThemeData.radiusSm),
                      border: Border.all(
                        color: _selectedTimeSlot == slot
                            ? theme.primary
                            : theme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedTimeSlot == slot
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _selectedTimeSlot == slot
                              ? theme.primary
                              : theme.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(slot,
                            style: theme.bodyMedium.override(
                              fontWeight:
                                  _selectedTimeSlot == slot ? FontWeight.w600 : FontWeight.normal,
                              color: theme.primaryText,
                            )),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBookingInfo(BuildContext context) {
    final theme = AppTheme.of(context);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.obBookingSummary,
              style: theme.titleSmall.override(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              )),
          const SizedBox(height: 12),
          _infoRow(theme, _l10n.obFeeService, '₱150.00'),
          _infoRow(theme, _l10n.obFeeUrgency, _urgencyDays == 0 ? '₱50.00' : '₱0.00'),
          _infoRow(theme, _l10n.obFeeServiceCharge, '₱20.00'),
          const Divider(height: 24),
          _infoRow(theme, _l10n.obTotal, '₱${_urgencyDays == 0 ? '220.00' : '170.00'}',
              bold: true, color: theme.primary),
        ],
      ),
    );
  }

  Widget _infoRow(AppThemeData theme, String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.bodyMedium.override(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? theme.primaryText,
                )),
          ),
          Text(value,
              style: theme.bodyMedium.override(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: color ?? theme.primaryText,
              )),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final theme = AppTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AppButton(
        onPressed: _selectedTimeSlot == null ? null : () {},
        backgroundColor: theme.primary,
        foregroundColor: theme.onPrimary,
        borderRadius: AppThemeData.radiusMd,
        width: double.infinity,
        child: Text(
          _l10n.obConfirmBooking,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
