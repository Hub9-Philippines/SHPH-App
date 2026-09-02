import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.size = 48,
    this.fontSize,
  });

  final String? photoUrl;
  final String? name;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
        ),
      );
    }

    return _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(AppThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: fontSize ?? size * 0.55,
        color: theme.primary,
        semanticLabel: name,
      ),
    );
  }
}
