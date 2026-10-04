import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Configuration for a bottom sheet the user can drag between extents.
class BookingResizableSheet {
  const BookingResizableSheet({
    required this.initialFraction,
    required this.minFraction,
    required this.maxFraction,
  });

  /// Fraction of the viewport the sheet occupies when first shown.
  final double initialFraction;

  /// Smallest extent the sheet may be dragged to.
  final double minFraction;

  /// Largest extent the sheet may be dragged to. Also caps how tall a measured
  /// sheet may grow, so the camera padding can never exceed this fraction.
  final double maxFraction;
}

/// Shared layout for booking screens that paint a map together with a bottom
/// sheet.
///
/// Two invariants this widget exists to enforce:
///
/// 1. The map is always `Positioned.fill`. Full-bleed coverage is structural,
///    so the map's bottom edge can never be bounded by a layout box again. The
///    sheet's surface is what occludes the map, never a gap.
/// 2. The map's camera padding is derived from the sheet's *measured* height —
///    or from its live drag extent when [resizable] is supplied — so it tracks
///    whatever step panel is currently shown. There is no pixel constant.
///
/// [mapBuilder] is invoked with the derived camera padding. It is called again
/// only when that padding actually changes (a step swap or a drag settle), so
/// the radar ripple's per-tick `ValueListenableBuilder` isolation is preserved:
/// ripple ticks rebuild the map's circle data inside the caller's own subtree
/// and are not routed through here.
class BookingMapSheetHost extends StatefulWidget {
  const BookingMapSheetHost({
    required this.mapBuilder,
    this.sheet,
    this.sheetBuilder,
    this.background,
    this.overlays = const <Widget>[],
    this.aboveSheet = const <Widget>[],
    this.resizable,
    this.maxSheetFraction = 0.64,
    this.fallbackSheetFraction = 0.45,
    this.topCameraPadding = 96,
    this.bottomCameraPadding = 24,
    this.horizontalCameraPadding = 16,
    this.includeBottomSafeArea = true,
    this.includeTopSafeArea = true,
    this.maxExtentBuilder,
    this.onSheetContentHeightChanged,
    this.onCameraPaddingChanged,
    this.removeBottomPaddingForDraggable = false,
    super.key,
  }) : assert(
          sheet != null || sheetBuilder != null,
          'Provide either sheet or sheetBuilder.',
        ),
       assert(
          !(sheet != null && sheetBuilder != null),
          'Provide sheet or sheetBuilder, not both.',
        );

  /// Builds the map, receiving the camera padding derived from the sheet.
  final Widget Function(BuildContext context, EdgeInsets cameraPadding)
      mapBuilder;

  /// Simple sheet content. The host measures it automatically.
  final Widget? sheet;

  /// Advanced sheet content. The host hands over its measurement callback so
  /// the sheet can report the height of its own scrollable content, and does
  /// *not* auto-wrap it. Also receives the [DraggableScrollableSheet]'s
  /// scroll controller when [resizable] is set (null otherwise).
  final Widget Function(
    BuildContext context,
    void Function(double height) onHeightChanged,
    ScrollController? scrollController,
  )?
      sheetBuilder;

  /// Painted *under* the map, filling the same box. An opaque map hides it
  /// entirely, so this is the background that shows through on a map-free
  /// layout.
  final Widget? background;

  /// Layers painted above the map but below the sheet — top cards, badges,
  /// scrims, centered content.
  final List<Widget> overlays;

  /// Layers painted above the sheet — cards that must stay on top of it.
  final List<Widget> aboveSheet;

  /// When set, the sheet is a [DraggableScrollableSheet] and the camera padding
  /// follows its live extent.
  final BookingResizableSheet? resizable;

  /// Hard ceiling on the sheet's height, as a fraction of the viewport. Also
  /// clamps the measured height so the camera padding stays sane when the
  /// content is taller than the viewport.
  final double maxSheetFraction;

  /// Fraction assumed for the first frame, before any measurement lands.
  /// Derived from the viewport rather than a pixel count.
  final double fallbackSheetFraction;

  /// Extra top inset for the camera, on top of the status bar.
  final double topCameraPadding;

  /// Extra bottom inset for the camera, below the sheet and nav-bar inset.
  final double bottomCameraPadding;

  /// Left and right camera insets.
  final double horizontalCameraPadding;

  /// Whether to add the nav-bar/gesture-bar inset to the camera's bottom
  /// padding. Leave this `true` when the sheet does *not* wrap its own content
  /// in a `SafeArea(top: false)`. Set it to `false` when the sheet already
  /// applies that inset itself, so the measured height is not double-counted.
  final bool includeBottomSafeArea;

  /// Whether to add the status-bar inset to the camera's top padding. Leave
  /// this `true` when the map extends behind the status bar. Set it to `false`
  /// when the map sits below a top bar, so [topCameraPadding] is used as-is.
  final bool includeTopSafeArea;

  /// When provided, computes the resizable sheet's max extent from the measured
  /// content height instead of using [BookingResizableSheet.maxFraction].
  /// `availableHeight` is the host's viewport height; `measuredContentHeight`
  /// is the latest reported sheet content height, or null before first measure.
  final double Function(
    double availableHeight,
    double? measuredContentHeight,
  )? maxExtentBuilder;

  /// Called whenever the sheet content reports a new measured height.
  /// Use this to react to height changes outside the host (e.g. reframing
  /// a route polyline). The host's own camera padding update happens regardless.
  final ValueChanged<double>? onSheetContentHeightChanged;

  /// Called whenever the derived camera padding updates.
  /// Use this to re-frame the map camera to keep pins or bounds centered.
  final ValueChanged<EdgeInsets>? onCameraPaddingChanged;

  /// When true, the draggable sheet is wrapped in `MediaQuery.removePadding`
  /// with `removeBottom: true` so the keyboard inset doesn't push it around.
  final bool removeBottomPaddingForDraggable;

  @override
  State<BookingMapSheetHost> createState() => _BookingMapSheetHostState();
}

class _BookingMapSheetHostState extends State<BookingMapSheetHost> {
  double? _sheetContentHeight;
  double _liveExtent = 0;
  EdgeInsets? _lastReportedCameraPadding;

  @override
  void initState() {
    super.initState();
    _liveExtent = widget.resizable?.initialFraction ?? 0;
  }

  @override
  void didUpdateWidget(covariant BookingMapSheetHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resizable?.initialFraction !=
        widget.resizable?.initialFraction) {
      _liveExtent = widget.resizable?.initialFraction ?? 0;
    }
    if ((oldWidget.sheet != widget.sheet) &&
        (oldWidget.sheetBuilder != widget.sheetBuilder)) {
      // A different step panel is on its way; fall back to the viewport-derived
      // estimate until the new panel reports its height, so the camera does not
      // briefly frame against the previous step's height.
      setState(() {
        _sheetContentHeight = null;
      });
    }
  }

  void _handleSheetContentHeightChanged(double height) {
    if (_sheetContentHeight == null ||
        (_sheetContentHeight! - height).abs() >= 1) {
      setState(() {
        _sheetContentHeight = height;
      });
    }
    widget.onSheetContentHeightChanged?.call(height);
  }

  bool _handleSheetNotification(DraggableScrollableNotification notification) {
    final extent = notification.extent;
    if ((extent - _liveExtent).abs() < 0.002) {
      return false;
    }
    setState(() {
      _liveExtent = extent;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final resizable = widget.resizable;
    final builder = widget.sheetBuilder;

    final Widget sheet;
    if (builder != null) {
      sheet = builder(context, _handleSheetContentHeightChanged, null);
    } else {
      sheet = SheetHeightMeasurer(
        onHeightChanged: _handleSheetContentHeightChanged,
        child: widget.sheet!,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight;
        final bottomInset =
            widget.includeBottomSafeArea ? mediaQuery.padding.bottom : 0.0;

        final double sheetFraction;
        final double maxExtent;
        if (resizable != null) {
          maxExtent = widget.maxExtentBuilder != null
              ? widget.maxExtentBuilder!(
                  viewportHeight,
                  _sheetContentHeight,
                )
              : resizable.maxFraction;
          sheetFraction = _liveExtent.clamp(
            resizable.minFraction,
            maxExtent,
          );
        } else {
          maxExtent = widget.maxSheetFraction;
          final measured = _sheetContentHeight;
          sheetFraction = measured == null
              ? widget.fallbackSheetFraction
              : (measured / viewportHeight).clamp(0.0, widget.maxSheetFraction);
        }

        final topInset =
            widget.includeTopSafeArea ? mediaQuery.padding.top : 0.0;

        final cameraPadding = EdgeInsets.only(
          top: topInset + widget.topCameraPadding,
          bottom: viewportHeight * sheetFraction +
              bottomInset +
              widget.bottomCameraPadding +
              mediaQuery.viewInsets.bottom,
          left: widget.horizontalCameraPadding,
          right: widget.horizontalCameraPadding,
        );

        if (widget.onCameraPaddingChanged != null &&
            _lastReportedCameraPadding != cameraPadding) {
          _lastReportedCameraPadding = cameraPadding;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onCameraPaddingChanged!(cameraPadding);
            }
          });
        }

        return Stack(
          children: <Widget>[
            if (widget.background != null)
              Positioned.fill(child: widget.background!),
            // Always full-bleed. The sheet occludes the map; nothing bounds it.
            Positioned.fill(child: widget.mapBuilder(context, cameraPadding)),
            ...widget.overlays,
            if (resizable != null)
              NotificationListener<DraggableScrollableNotification>(
                onNotification: _handleSheetNotification,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _ResizableSheetHost(
                    resizable: resizable,
                    maxExtent: maxExtent,
                    removeBottomPadding: widget.removeBottomPaddingForDraggable,
                    sheetBuilder: builder,
                    sheet: sheet,
                    onHeightChanged: _handleSheetContentHeightChanged,
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: viewportHeight * widget.maxSheetFraction,
                  ),
                  child: sheet,
                ),
              ),
            ...widget.aboveSheet,
          ],
        );
      },
    );
  }
}

/// Wraps a sheet and reports its laid-out height so the host can derive the
/// map's camera padding. Sub-pixel changes are ignored to avoid a rebuild loop.
class SheetHeightMeasurer extends SingleChildRenderObjectWidget {
  const SheetHeightMeasurer({
    required this.onHeightChanged,
    required super.child,
    super.key,
  });

  final ValueChanged<double> onHeightChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SheetHeightMeasureRenderObject(onHeightChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _SheetHeightMeasureRenderObject renderObject,
  ) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _SheetHeightMeasureRenderObject extends RenderProxyBox {
  _SheetHeightMeasureRenderObject(this.onHeightChanged);

  ValueChanged<double> onHeightChanged;

  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final height = child?.size.height;
    if (height == null) {
      return;
    }
    final previous = _lastHeight;
    if (previous != null && (previous - height).abs() < 1) {
      return;
    }
    _lastHeight = height;
    final measured = height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onHeightChanged(measured);
    });
  }
}

class _ResizableSheetHost extends StatelessWidget {
  const _ResizableSheetHost({
    required this.resizable,
    required this.maxExtent,
    required this.removeBottomPadding,
    required this.sheetBuilder,
    required this.sheet,
    required this.onHeightChanged,
  });

  final BookingResizableSheet resizable;
  final double maxExtent;
  final bool removeBottomPadding;
  final Widget Function(
    BuildContext,
    void Function(double),
    ScrollController?,
  )? sheetBuilder;
  final Widget sheet;
  final void Function(double) onHeightChanged;

  @override
  Widget build(BuildContext context) {
    Widget content = DraggableScrollableSheet(
      initialChildSize: resizable.initialFraction,
      minChildSize: resizable.minFraction,
      maxChildSize: maxExtent,
      builder: (context, scrollController) => sheetBuilder != null
          ? sheetBuilder!(context, onHeightChanged, scrollController)
          : sheet,
    );

    if (removeBottomPadding) {
      content = MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: content,
      );
    }

    return content;
  }
}
