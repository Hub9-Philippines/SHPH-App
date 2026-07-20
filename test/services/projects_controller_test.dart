import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/models/paginated_response.dart';
import 'package:serbisyohubph/api/models/project.dart';
import 'package:serbisyohubph/services/projects_controller.dart';

void main() {
  late ProjectsHarness harness;

  setUp(() => harness = ProjectsHarness());

  test('loads projects and exposes ready state', () async {
    harness.listed = [project(1), project(2)];

    expect(await harness.controller.load(status: 'matching'), isTrue);

    expect(harness.controller.state, ProjectsState.ready);
    expect(harness.controller.projects.map((item) => item.id), [1, 2]);
    expect(harness.calls, ['list:matching']);
  });

  test('create prepends and quote replaces without duplicating', () async {
    harness.listed = [project(1), project(2)];
    await harness.controller.load();
    harness.created = project(3, status: 'draft');

    final created = await harness.controller.create({
      'title': 'Three',
      'description': 'Description',
      'category': 1,
    });
    harness.quoted = project(3, status: 'quoted');
    expect(await harness.controller.quote(), isTrue);

    expect(created?.id, 3);
    expect(harness.controller.currentProject?.isQuoted, isTrue);
    expect(harness.controller.projects.map((item) => item.id), [3, 1, 2]);
  });

  test('match refreshes the current project after the mutation', () async {
    harness.details[1] = project(1);
    await harness.controller.open(1);
    harness.details[1] = project(1, status: 'matching');

    expect(await harness.controller.match(9), isTrue);

    expect(harness.calls, containsAllInOrder(['match:1:9', 'detail:1']));
    expect(harness.controller.currentProject?.isMatching, isTrue);
  });

  test('prospect action refreshes current detail', () async {
    harness.details[1] = project(1);
    await harness.controller.open(1);
    harness.calls.clear();

    expect(
      await harness.controller.actOnProspect(
        prospectId: 5,
        action: 'accept',
        agreedPrice: 1200,
      ),
      isTrue,
    );

    expect(harness.calls, ['prospect:5:accept:1200.0', 'detail:1']);
  });

  test('rejects concurrent operations without issuing another request',
      () async {
    final pending = Completer<PaginatedResponse<ShphProject>>();
    harness.pendingList = pending.future;

    final first = harness.controller.load();
    expect(harness.controller.isBusy, isTrue);
    expect(await harness.controller.open(1), isFalse);
    expect(harness.calls, ['list:null']);

    pending.complete(
      const PaginatedResponse<ShphProject>(count: 0, results: []),
    );
    expect(await first, isTrue);
  });

  test('failure exposes a safe message and preserves existing data', () async {
    harness.listed = [project(1)];
    await harness.controller.load();
    harness.failDetail = true;

    expect(await harness.controller.open(2), isFalse);

    expect(harness.controller.state, ProjectsState.error);
    expect(harness.controller.errorMessage, 'Unable to load this project.');
    expect(harness.controller.projects.single.id, 1);
  });

  test('cancel removes the project and clears current selection', () async {
    harness.listed = [project(1), project(2)];
    await harness.controller.load();
    harness.details[1] = project(1);
    await harness.controller.open(1);

    expect(await harness.controller.cancel(), isTrue);

    expect(harness.controller.currentProject, isNull);
    expect(harness.controller.projects.map((item) => item.id), [2]);
    expect(harness.calls, contains('cancel:1'));
  });
}

ShphProject project(int id, {String status = 'draft'}) => ShphProject(
      id: id,
      title: 'Project $id',
      description: 'Description $id',
      category: 1,
      status: status,
    );

class ProjectsHarness {
  ProjectsHarness() {
    controller = ProjectsController(
      loadProjects: ({status, page, pageSize}) async {
        calls.add('list:$status');
        final pending = pendingList;
        if (pending != null) {
          return pending;
        }
        return PaginatedResponse(count: listed.length, results: listed);
      },
      loadProject: (id) async {
        calls.add('detail:$id');
        if (failDetail) {
          throw StateError('private backend detail');
        }
        return details[id] ?? project(id);
      },
      createProject: (payload) async {
        calls.add('create');
        return created;
      },
      quoteProject: (id, {contextHint, maxRoleLines}) async {
        calls.add('quote:$id');
        return quoted;
      },
      matchProject: (id, {required roleLineId}) async {
        calls.add('match:$id:$roleLineId');
        return ShphProjectRoleLine(
          id: roleLineId,
          roleLabel: 'Role',
          headcount: 1,
        );
      },
      cancelProject: (id) async {
        calls.add('cancel:$id');
        return project(id, status: 'cancelled');
      },
      actOnProspect: (
          {required prospectId, required action, agreedPrice}) async {
        calls.add('prospect:$prospectId:$action:$agreedPrice');
        return ShphProjectProspect(
          id: prospectId,
          provider: 1,
          status: action == 'accept' ? 'accepted' : action,
        );
      },
    );
  }

  final List<String> calls = [];
  final Map<int, ShphProject> details = {};
  late final ProjectsController controller;
  List<ShphProject> listed = [];
  ShphProject created = project(3);
  ShphProject quoted = project(3, status: 'quoted');
  Future<PaginatedResponse<ShphProject>>? pendingList;
  bool failDetail = false;
}
