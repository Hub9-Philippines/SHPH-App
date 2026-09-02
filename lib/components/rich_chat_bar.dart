import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_text_field.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class RichChatBar extends StatelessWidget {
  const RichChatBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachImage,
    this.onVoiceMessage,
    this.onSticker,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachImage;
  final VoidCallback? onVoiceMessage;
  final VoidCallback? onSticker;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (onSticker != null)
              IconButton(
                onPressed: onSticker,
                icon: Icon(Icons.emoji_emotions_outlined,
                    color: theme.textTertiary),
              ),
            if (onAttachImage != null)
              IconButton(
                onPressed: onAttachImage,
                icon:
                    Icon(Icons.image_outlined, color: theme.textTertiary),
              ),
            Expanded(
              child: AppTextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => onSend(),
                placeholder: _l10n.ccTypeMessage,
                placeholderStyle: theme.bodyMedium.override(
                  color: theme.textTertiary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                fillColor: theme.secondaryBackground,
                radius: 24,
                style: theme.bodyMedium.override(
                  color: theme.primaryText,
                ),
              ),
            ),
            if (onVoiceMessage != null)
              IconButton(
                onPressed: onVoiceMessage,
                icon: Icon(Icons.mic_rounded,
                    color: theme.textTertiary),
              ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded,
                    color: theme.onPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
