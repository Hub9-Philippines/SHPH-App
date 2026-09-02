import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

/// Canonical pull-to-refresh for the app: Material [RefreshIndicator]
/// wrapping a bouncy, always-scrollable [CustomScrollView]. Pulling from
/// the top triggers [onRefresh] even on short content.
mixin RefreshablePage<T extends StatefulWidget> on State<T> {
  Future<void> onRefresh();

  /// Wraps [slivers] in a bouncy, always-scrollable `CustomScrollView`
  /// inside a [RefreshIndicator], so pulling from the top triggers
  /// [onRefresh] even on short content.
  ///
  /// Pass [scrollKey] (e.g. a `ValueKey` that changes per refresh) when
  /// the caller wants the scroll position reset after each successful
  /// reload. Pass [controller] when the caller needs to observe scroll
  /// offset (e.g. for a collapsing header).
  Widget wrapWithRefresh({
    required List<Widget> slivers,
    Key? scrollKey,
    ScrollController? controller,
  }) {
    final theme = AppTheme.of(context);
    return RefreshIndicator(
      color: const Color(0xFF14B8A6),
      backgroundColor: theme.primaryBackground,
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: scrollKey,
        controller: controller,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: slivers,
      ),
    );
  }
}
