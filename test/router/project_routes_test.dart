import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/pages/projects/project_create_page.dart';
import 'package:serbisyohubph/pages/projects/project_detail_page.dart';
import 'package:serbisyohubph/pages/projects/project_list_page.dart';
import 'package:serbisyohubph/router/project_routes.dart';

void main() {
  test('all project route surfaces use the protected prefix', () {
    expect(isProtectedProjectPath(ProjectListPage.routePath), isTrue);
    expect(isProtectedProjectPath(ProjectCreatePage.routePath), isTrue);
    expect(isProtectedProjectPath(ProjectDetailPage.routePath), isTrue);
    expect(isProtectedProjectPath('/project'), isFalse);
    expect(isProtectedProjectPath('/projects-archive'), isFalse);
  });

  test('accepts only positive numeric project route ids', () {
    expect(parseProjectRouteId('42'), 42);
    expect(parseProjectRouteId(null), 0);
    expect(parseProjectRouteId(''), 0);
    expect(parseProjectRouteId('abc'), 0);
    expect(parseProjectRouteId('0'), 0);
    expect(parseProjectRouteId('-1'), 0);
  });
}
