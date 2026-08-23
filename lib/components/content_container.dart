import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

enum ContentVariant { narrow, readable, wide, dashboard, full }

class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.variant = ContentVariant.wide,
    this.padded = false,
    this.center = false,
  });

  final Widget child;
  final ContentVariant variant;
  final bool padded;
  final bool center;

  double get _maxWidth {
    switch (variant) {
      case ContentVariant.narrow:
        return AppThemeData.containerNarrow;
      case ContentVariant.readable:
        return AppThemeData.containerReadable;
      case ContentVariant.wide:
        return AppThemeData.containerWide;
      case ContentVariant.dashboard:
        return AppThemeData.containerDashboard;
      case ContentVariant.full:
        return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    var paddedChild = child;
    if (padded) {
      paddedChild = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: paddedChild,
      );
    }
    if (center) {
      paddedChild = Align(
        alignment: Alignment.topCenter,
        child: paddedChild,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxWidth),
        child: paddedChild,
      ),
    );
  }
}
