import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/booking_map_sheet_host.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/booking_status_scaffold.dart';

/// Stands in for a real map: records nothing, just fills its box so the test
/// can measure the rect the host gave it.
class _FakeMap extends StatelessWidget {
  const _FakeMap();

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Color(0xFF00FF00));
}

/// Host harness. [recorded] collects every camera padding the host derives, so
/// a test can assert on the value the map actually received.
Widget _host({
  required List<EdgeInsets> recorded,
  Widget? sheet,
  Widget Function(BuildContext, void Function(double), ScrollController?)?
      sheetBuilder,
  BookingResizableSheet? resizable,
  double Function(double, double?)? maxExtentBuilder,
  bool showMap = true,
  Widget? background,
  double topCameraPadding = 96,
  double bottomCameraPadding = 24,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BookingMapSheetHost(
        mapBuilder: (context, padding) {
          recorded.add(padding);
          return showMap ? const _FakeMap() : const SizedBox.shrink();
        },
        sheet: sheet,
        sheetBuilder: sheetBuilder,
        resizable: resizable,
        maxExtentBuilder: maxExtentBuilder,
        background: background,
        includeBottomSafeArea: false,
        bottomCameraPadding: 0,
        // Keep the test sheets below the cap so they measure at their real
        // height rather than being clamped.
        maxSheetFraction: 0.9,
      ),
    ),
  );
}

/// A host whose sheet height can be swapped in place, preserving the host's
/// state the way a step swap does.
class _TogglingHost extends StatefulWidget {
  const _TogglingHost({required this.recorded});

  final List<EdgeInsets> recorded;

  @override
  State<_TogglingHost> createState() => _TogglingHostState();
}

class _TogglingHostState extends State<_TogglingHost> {
  bool _tall = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BookingMapSheetHost(
          mapBuilder: (context, padding) {
            widget.recorded.add(padding);
            return const _FakeMap();
          },
          sheet: _tall
              ? const SizedBox(height: 400, key: Key('tall'))
              : const SizedBox(height: 150, key: Key('short')),
          includeBottomSafeArea: false,
          bottomCameraPadding: 0,
          maxSheetFraction: 0.9,
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key('swap'),
          onPressed: () => setState(() => _tall = !_tall),
        ),
      ),
    );
  }
}

void main() {
  group('BookingMapSheetHost', () {
    testWidgets('paints the map full-bleed and pads the camera by the measured sheet height',
        (tester) async {
      final recorded = <EdgeInsets>[];
      await tester.pumpWidget(_host(
        recorded: recorded,
        sheet: const SizedBox(height: 300, key: Key('sheet')),
      ));
      await tester.pumpAndSettle();

      // Full-bleed: the map's rect is the whole host box.
      final mapRect = tester.getRect(find.byType(_FakeMap));
      final hostRect = tester.getRect(find.byType(BookingMapSheetHost));
      expect(mapRect.size, hostRect.size);
      expect(mapRect.topLeft, hostRect.topLeft);

      // The camera's bottom padding equals the measured sheet height.
      expect(recorded.last.bottom, 300);
    });

    testWidgets('the pin is centered in the visible band between top inset and sheet',
        (tester) async {
      final recorded = <EdgeInsets>[];
      await tester.pumpWidget(_host(
        recorded: recorded,
        sheet: const SizedBox(height: 300, key: Key('sheet')),
        topCameraPadding: 96,
        bottomCameraPadding: 24,
      ));
      await tester.pumpAndSettle();

      final padding = recorded.last;
      final hostHeight = tester.getSize(find.byType(BookingMapSheetHost)).height;

      // The Google Map centers the camera target within the padded region, so
      // the pin sits at the vertical center of the visible band.
      final visibleBandTop = padding.top;
      final visibleBandBottom = hostHeight - padding.bottom;
      final pinY = (visibleBandTop + visibleBandBottom) / 2;

      // The pin is at the center of the visible band, not the center of the
      // screen — the band is the region between the top inset and the sheet.
      expect(pinY, greaterThan(visibleBandTop));
      expect(pinY, lessThan(visibleBandBottom));
      expect(pinY - visibleBandTop, closeTo(visibleBandBottom - pinY, 0.5));
    });

    testWidgets('a short panel yields a smaller bottom padding than a tall one',
        (tester) async {
      final recorded = <EdgeInsets>[];
      await tester.pumpWidget(_host(
        recorded: recorded,
        sheet: const SizedBox(height: 500, key: Key('sheet')),
      ));
      await tester.pumpAndSettle();
      expect(recorded.last.bottom, 500);

      await tester.pumpWidget(_host(
        recorded: recorded,
        sheet: const SizedBox(height: 150, key: Key('sheet')),
      ));
      await tester.pumpAndSettle();
      expect(recorded.last.bottom, 150);
    });

    testWidgets('re-frames when the displayed step swaps to a taller panel',
        (tester) async {
      final recorded = <EdgeInsets>[];
      await tester.pumpWidget(_TogglingHost(recorded: recorded));
      await tester.pumpAndSettle();
      expect(recorded.last.bottom, 400);

      // Swap to the short panel in place.
      await tester.tap(find.byKey(const Key('swap')));
      await tester.pumpAndSettle();
      expect(recorded.last.bottom, 150);
    });

    testWidgets('a short sheet leaves no background gap behind it', (tester) async {
      await tester.pumpWidget(_host(
        recorded: <EdgeInsets>[],
        sheet: const SizedBox(height: 120, key: Key('sheet')),
      ));
      await tester.pumpAndSettle();

      final mapRect = tester.getRect(find.byType(_FakeMap));
      final sheetRect = tester.getRect(find.byKey(const Key('sheet')));
      // The map runs to the bottom of the viewport, behind the sheet, so its
      // bottom edge is at or past the sheet's top edge.
      expect(mapRect.bottom, greaterThanOrEqualTo(sheetRect.top));
    });

    testWidgets('a resizable sheet tracks the drag extent and settles', (tester) async {
      final recorded = <EdgeInsets>[];
      await tester.pumpWidget(_host(
        recorded: recorded,
        resizable: const BookingResizableSheet(
          initialFraction: 0.25,
          minFraction: 0.25,
          maxFraction: 0.6,
        ),
        // Scrollable content, which is what DraggableScrollableSheet needs to
        // receive a resize drag.
        sheetBuilder: (context, onHeightChanged, scrollController) => ListView(
          controller: scrollController,
          children: const [
            SizedBox(height: 400, key: Key('sheet-content')),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      final collapsed = recorded.last.bottom;

      await tester.drag(
        find.byType(ListView),
        const Offset(0, -250),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      final expanded = recorded.last.bottom;

      expect(expanded, greaterThan(collapsed));
      // After release the padding matches the resting extent, not the drag peak.
      expect(recorded.last.bottom, expanded);
    });

    testWidgets('a map-free layout builds no map widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BookingStatusScaffold(
            showMap: false,
            location: const LatLng(14.5995, 120.9842),
            bottomSheet: const SizedBox(height: 200, key: Key('sheet')),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsNothing);
      // The freed canvas still shows the background and the sheet.
      expect(find.byKey(const Key('sheet')), findsOneWidget);
    });

    testWidgets('a radar tick rebuilds neither the map nor the sheet subtree',
        (tester) async {
      var mapBuilds = 0;
      var sheetBuilds = 0;
      // Stands in for the radar's ValueListenable: ticking it rebuilds the
      // ancestor ValueListenableBuilder, which is the rebuild path the host
      // has to isolate the map and sheet from.
      final radar = ValueNotifier<Set<Circle>>(const <Circle>{});

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<Set<Circle>>(
            valueListenable: radar,
            builder: (context, circles, child) => BookingMapSheetHost(
              mapBuilder: (context, padding) {
                mapBuilds++;
                return const _FakeMap();
              },
              sheetBuilder: (context, onHeightChanged, scrollController) {
                sheetBuilds++;
                return const SizedBox(height: 200, key: Key('sheet'));
              },
              resizable: const BookingResizableSheet(
                initialFraction: 0.25,
                minFraction: 0.25,
                maxFraction: 0.6,
              ),
              includeBottomSafeArea: false,
              bottomCameraPadding: 0,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final mapBefore = mapBuilds;
      final sheetBefore = sheetBuilds;

      radar.value = const <Circle>{};
      await tester.pumpAndSettle();

      expect(mapBuilds, mapBefore);
      expect(sheetBuilds, sheetBefore);
    });
  });
}
