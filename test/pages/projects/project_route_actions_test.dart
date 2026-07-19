import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/api/models/category.dart';
import 'package:serbisyohubph/api/models/paginated_response.dart';
import 'package:serbisyohubph/api/models/project.dart';
import 'package:serbisyohubph/pages/projects/project_create_page.dart';
import 'package:serbisyohubph/pages/projects/project_detail_page.dart';
import 'package:serbisyohubph/services/projects_controller.dart';

void main() {
  late PageHarness harness;

  setUp(() => harness = PageHarness());

  testWidgets('create route submits validated controller payload',
      (tester) async {
    await tester.pumpWidget(_wrap(
      harness.controller,
      ProjectCreatePage(
        categoryLoader: () async => const [
          ShphCategory(id: 4, name: 'Construction'),
        ],
      ),
    ));
    await _flush(tester);

    await tester.enterText(
      find.byKey(const Key('project_title_field')),
      ' Office renovation ',
    );
    await tester.enterText(
      find.byKey(const Key('project_description_field')),
      ' Renovate two floors ',
    );
    await tester.tap(find.byKey(const Key('project_category_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Construction').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('project_submit_btn')));
    await _flush(tester);

    expect(harness.createdPayload, {
      'title': 'Office renovation',
      'description': 'Renovate two floors',
      'category': 4,
      'is_b2b': false,
    });
  });

  testWidgets('detail route generates a quote through the controller',
      (tester) async {
    harness.detail = project(1);
    await tester.pumpWidget(
      _wrap(harness.controller, const ProjectDetailPage(projectId: 1)),
    );
    await _flush(tester);

    await tester.tap(find.byKey(const Key('project_quote_btn')));
    await _flush(tester);

    expect(harness.calls, contains('quote:1'));
    expect(harness.controller.currentProject?.isQuoted, isTrue);
  });

  testWidgets('detail route matches a role and refreshes detail',
      (tester) async {
    harness.detail = project(1, status: 'quoted', withRole: true);
    await tester.pumpWidget(
      _wrap(harness.controller, const ProjectDetailPage(projectId: 1)),
    );
    await _flush(tester);
    harness.calls.clear();

    await tester.tap(find.text('Match'));
    await _flush(tester);

    expect(harness.calls, ['match:1:9', 'detail:1']);
  });

  testWidgets('detail route confirms cancellation before mutation',
      (tester) async {
    harness.detail = project(1);
    await tester.pumpWidget(
      _wrap(harness.controller, const ProjectDetailPage(projectId: 1)),
    );
    await _flush(tester);

    await tester.tap(find.byKey(const Key('project_cancel_btn')));
    await tester.pumpAndSettle();
    expect(harness.calls.where((call) => call.startsWith('cancel:')), isEmpty);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel project'));
    await _flush(tester);

    expect(harness.calls, contains('cancel:1'));
    expect(harness.controller.currentProject, isNull);
  });

  testWidgets('detail route never renders a stale project id', (tester) async {
    harness.detail = project(1);
    await harness.controller.open(1);
    final delayed = Completer<ShphProject>();
    harness.pendingDetail = delayed.future;

    await tester.pumpWidget(
      _wrap(harness.controller, const ProjectDetailPage(projectId: 2)),
    );
    await tester.pump();

    expect(find.text('Project 1'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    delayed.complete(project(2));
    await _flush(tester);
    expect(find.text('Project 2'), findsOneWidget);
  });
}

Widget _wrap(ProjectsController controller, Widget child) => MaterialApp(
      home: ChangeNotifierProvider<ProjectsController>.value(
        value: controller,
        child: child,
      ),
    );

Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await Future<void>.delayed(Duration.zero);
  await tester.pump();
}

ShphProject project(
  int id, {
  String status = 'draft',
  bool withRole = false,
}) =>
    ShphProject(
      id: id,
      title: 'Project $id',
      description: 'Description $id',
      category: 4,
      status: status,
      roleLines: withRole
          ? const [
              ShphProjectRoleLine(
                id: 9,
                roleLabel: 'Electrician',
                headcount: 2,
              ),
            ]
          : const [],
    );

class PageHarness {
  PageHarness() {
    controller = ProjectsController(
      loadProjects: ({status, page, pageSize}) async =>
          const PaginatedResponse(count: 0, results: []),
      loadProject: (id) async {
        calls.add('detail:$id');
        final pending = pendingDetail;
        if (pending != null) {
          return pending;
        }
        return detail;
      },
      createProject: (payload) async {
        calls.add('create');
        createdPayload = Map.of(payload);
        return project(3);
      },
      quoteProject: (id, {contextHint, maxRoleLines}) async {
        calls.add('quote:$id');
        detail = project(id, status: 'quoted', withRole: true);
        return detail;
      },
      matchProject: (id, {required roleLineId}) async {
        calls.add('match:$id:$roleLineId');
        return const ShphProjectRoleLine(
          id: 9,
          roleLabel: 'Electrician',
          headcount: 2,
        );
      },
      cancelProject: (id) async {
        calls.add('cancel:$id');
        return project(id, status: 'cancelled');
      },
      actOnProspect: (
              {required prospectId, required action, agreedPrice}) async =>
          ShphProjectProspect(id: prospectId, provider: 1, status: action),
    );
  }

  final List<String> calls = [];
  late final ProjectsController controller;
  late ShphProject detail;
  Map<String, dynamic>? createdPayload;
  Future<ShphProject>? pendingDetail;
}
