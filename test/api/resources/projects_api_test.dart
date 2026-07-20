import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/resources/projects_api.dart';

void main() {
  late FakeProjectsTransport transport;
  late ShphProjectsApi api;

  setUp(() {
    transport = FakeProjectsTransport();
    api = ShphProjectsApi(transport: transport);
  });

  test('creates a validated project', () async {
    transport.response = {'id': 1, 'title': 'Build', 'description': 'Work'};

    final project = await api.create({
      'title': 'Build',
      'description': 'Work',
      'category': 4,
      'is_b2b': true,
    });

    expect(project.id, 1);
    expect(transport.last.path, '/api/projects/');
    expect(transport.last.data?['category'], 4);
  });

  test('lists projects through the POST-over-GET contract', () async {
    transport.response = {
      'count': 1,
      'results': [
        {'id': 2, 'title': 'Project', 'description': 'Description'},
      ],
    };

    final result = await api.list(status: ' matching ', page: 2, pageSize: 20);

    expect(result.count, 1);
    expect(result.results.single.id, 2);
    expect(transport.last.path, '/api/projects/list/');
    expect(transport.last.data, {
      'status': 'matching',
      'page': 2,
      'page_size': 20,
    });
  });

  test('uses verified detail, quote, match, and cancel paths', () async {
    transport.response = {'id': 7, 'title': 'Project', 'description': 'Work'};

    await api.detail(7);
    expect(transport.last.path, '/api/projects/7/');
    await api.quote(7, contextHint: ' urgent ', maxRoleLines: 3);
    expect(transport.last.path, '/api/projects/7/quote/');
    expect(transport.last.data, {
      'context_hint': 'urgent',
      'max_role_lines': 3,
    });
    transport.response = {'id': 8, 'role_label': 'Electrician', 'headcount': 2};
    final roleLine = await api.match(7, roleLineId: 8);
    expect(transport.last.path, '/api/projects/7/match/');
    expect(transport.last.data, {'role_line_id': 8});
    expect(roleLine.id, 8);
    expect(roleLine.roleLabel, 'Electrician');
    transport.response = {'id': 7, 'title': 'Project', 'description': 'Work'};
    await api.cancel(7);
    expect(transport.last.path, '/api/projects/7/cancel/');
  });

  test('sends normalized prospect actions', () async {
    transport.response = {'id': 3, 'status': 'accepted'};

    final result = await api.prospectAction(
      prospectId: 3,
      action: ' accept ',
      agreedPrice: 1500,
    );

    expect(result.status, 'accepted');
    expect(transport.last.path, '/api/projects/prospects/action/');
    expect(transport.last.data, {
      'prospect_id': 3,
      'action': 'accept',
      'agreed_price': 1500,
    });
  });

  test('rejects invalid requests before network access', () async {
    expect(
      () => api.create({'title': '', 'description': 'x', 'category': 1}),
      throwsFormatException,
    );
    expect(() => api.list(page: 0), throwsFormatException);
    expect(() => api.list(pageSize: 101), throwsFormatException);
    expect(() => api.detail(0), throwsFormatException);
    expect(() => api.quote(1, maxRoleLines: 0), throwsFormatException);
    expect(() => api.match(1, roleLineId: -1), throwsFormatException);
    expect(
      () => api.prospectAction(prospectId: 1, action: ''),
      throwsFormatException,
    );
    expect(
      () => api.prospectAction(
        prospectId: 1,
        action: 'accept',
        agreedPrice: double.nan,
      ),
      throwsFormatException,
    );
    expect(transport.requests, isEmpty);
  });
}

class FakeProjectsTransport implements ProjectsApiTransport {
  final List<ProjectRequest> requests = [];
  Map<String, dynamic> response = {};

  ProjectRequest get last => requests.last;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    requests.add(ProjectRequest(path, data));
    return response;
  }
}

class ProjectRequest {
  const ProjectRequest(this.path, this.data);

  final String path;
  final Map<String, dynamic>? data;
}
