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

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

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
          errorBuilder: (_, __, ___) => _buildInitials(theme),
        ),
      );
    }

    return _buildInitials(theme);
  }

  Widget _buildInitials(AppThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? size * 0.4,
        ),
      ),
    );
  }
}
