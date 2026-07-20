import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/models/project.dart';

void main() {
  test('parses deployed project, role-line, and prospect shapes', () {
    final project = ShphProject.fromJson({
      'id': 12,
      'title': 'Office fit-out',
      'description': 'Renovate two floors',
      'category': 4,
      'category_name': 'Construction',
      'client': 7,
      'is_b2b': true,
      'status': 'matching',
      'estimated_budget_min': '100000.50',
      'estimated_headcount': 3,
      'client_lat': '14.5995',
      'role_lines': [
        {
          'id': 21,
          'role_label': 'Electrician',
          'headcount': 2,
          'est_rate_min': '800.00',
          'prospects': [
            {
              'id': 31,
              'provider': 44,
              'score': '0.91',
              'rating_snapshot': '4.8',
              'status': 'shortlisted',
              'booking': '55',
            },
          ],
        },
      ],
    });

    expect(project.id, 12);
    expect(project.isB2b, isTrue);
    expect(project.isMatching, isTrue);
    expect(project.estimatedBudgetMin, 100000.5);
    expect(project.clientLat, 14.5995);
    expect(project.roleLines.single.estRateMin, 800);
    expect(project.roleLines.single.prospects.single.score, 0.91);
    expect(project.roleLines.single.prospects.single.booking, 55);
    expect(project.roleLines.single.prospects.single.isShortlisted, isTrue);
  });

  test('accepts numeric strings and safely defaults malformed optional data',
      () {
    final project = ShphProject.fromJson({
      'id': '9',
      'title': 123,
      'description': 'Description',
      'category': '5',
      'estimated_headcount': '4',
      'role_lines': ['bad', null],
    });

    expect(project.id, 9);
    expect(project.title, '123');
    expect(project.category, 5);
    expect(project.estimatedHeadcount, 4);
    expect(project.roleLines, isEmpty);
    expect(project.isDraft, isTrue);
  });

  test('cancelled and expired projects are inactive', () {
    ShphProject project(String status) => ShphProject(
          id: 1,
          title: 'Title',
          description: 'Description',
          category: 1,
          status: status,
        );

    expect(project('draft').isActive, isTrue);
    expect(project('cancelled').isActive, isFalse);
    expect(project('expired').isActive, isFalse);
  });
}
