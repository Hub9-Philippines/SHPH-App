import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/pages/projects/project_create_page.dart';

void main() {
  test('requires meaningful project title and description text', () {
    expect(requiredProjectText(null), 'Required');
    expect(requiredProjectText(''), 'Required');
    expect(requiredProjectText('   '), 'Required');
    expect(requiredProjectText('Office renovation'), isNull);
  });
}
