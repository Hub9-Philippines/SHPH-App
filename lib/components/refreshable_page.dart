import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

mixin RefreshablePage<T extends StatefulWidget> on State<T> {
  Future<void> onRefresh();

  Widget wrapWithRefresh({required Widget child}) => RefreshIndicator(
      color: AppTheme.of(context).primary,
      onRefresh: onRefresh,
      child: child,
    );
}
