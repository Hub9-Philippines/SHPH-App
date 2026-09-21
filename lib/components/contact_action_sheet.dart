import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

enum ContactActionKind { call, message, all }

enum ContactActionChoice { callByNumber, inAppCall, textSms, inAppChat }

/// Presents the two contact options for a booking-details action (call or
/// message) in a themed bottom sheet and returns the chosen one via
/// [Navigator.pop]. Phone-dependent options are disabled when [phoneAvailable]
/// is false. The caller is responsible for acting on the returned choice.
Future<ContactActionChoice?> showContactActionSheet(
  BuildContext context, {
  required ContactActionKind kind,
  required String providerName,
  required bool phoneAvailable,
}) {
  return showModalBottomSheet<ContactActionChoice>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => ContactActionSheet(
      kind: kind,
      providerName: providerName,
      phoneAvailable: phoneAvailable,
    ),
  );
}

class ContactActionSheet extends StatelessWidget {
  const ContactActionSheet({
    super.key,
    required this.kind,
    required this.providerName,
    required this.phoneAvailable,
  });

  final ContactActionKind kind;
  final String providerName;
  final bool phoneAvailable;

  AppLocalizations? _l10n(BuildContext context) => AppLocalizations.of(context);

  List<(ContactActionChoice, IconData, String, String?)> _options(
    AppLocalizations l10n,
  ) {
    if (kind == ContactActionKind.call) {
      return [
        (
          ContactActionChoice.callByNumber,
          Icons.call_rounded,
          l10n.caCallByNumber,
          phoneAvailable ? null : l10n.cpPhoneUnavailable,
        ),
        (
          ContactActionChoice.inAppCall,
          Icons.headset_mic_rounded,
          l10n.caInAppCall,
          null,
        ),
      ];
    }
    if (kind == ContactActionKind.all) {
      return [
        (
          ContactActionChoice.inAppChat,
          Icons.chat_bubble_rounded,
          l10n.caInAppChat,
          null,
        ),
        (
          ContactActionChoice.inAppCall,
          Icons.headset_mic_rounded,
          l10n.caInAppCall,
          null,
        ),
        if (phoneAvailable) ...[
          (
            ContactActionChoice.callByNumber,
            Icons.call_rounded,
            l10n.caCallByNumber,
            null,
          ),
          (
            ContactActionChoice.textSms,
            Icons.sms_outlined,
            l10n.caTextSms,
            null,
          ),
        ] else ...[
          (ContactActionChoice.callByNumber, Icons.call_rounded, l10n.caCallByNumber, l10n.cpPhoneUnavailable),
          (ContactActionChoice.textSms, Icons.sms_outlined, l10n.caTextSms, l10n.cpPhoneUnavailable),
        ],
      ];
    }
    return [
      (
        ContactActionChoice.textSms,
        Icons.sms_outlined,
        l10n.caTextSms,
        phoneAvailable ? null : l10n.cpPhoneUnavailable,
      ),
      (
        ContactActionChoice.inAppChat,
        Icons.chat_bubble_rounded,
        l10n.caInAppChat,
        null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = _l10n(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              switch (kind) {
                ContactActionKind.call => l10n.bdCallProvider,
                ContactActionKind.message => l10n.bdMessageProvider,
                ContactActionKind.all => l10n.cpTitle,
              },
              style: theme.titleMedium.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              providerName,
              style: theme.bodySmall.override(
                font: GoogleFonts.plusJakartaSans(),
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            for (final (choice, icon, label, subtitle) in _options(l10n)) ...[
              _OptionTile(
                icon: icon,
                label: label,
                subtitle: subtitle,
                clipColor: theme.primary.withValues(alpha: 0.12),
                clipIcon: theme.primary,
                labelColor: theme.primaryText,
                enabled: subtitle == null,
                onTap: () => Navigator.of(context).pop(choice),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: theme.labelMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                    color: theme.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.clipColor,
    required this.clipIcon,
    required this.labelColor,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color clipColor;
  final Color clipIcon;
  final Color labelColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: ListTile(
        onTap: enabled ? onTap : null,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? clipColor : theme.border,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: enabled ? clipIcon : theme.textTertiary,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
            ),
            color: enabled ? labelColor : theme.textTertiary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.secondaryText,
                ),
              )
            : null,
        trailing: enabled ? const Icon(Icons.chevron_right_rounded) : null,
      ),
    );
  }
}