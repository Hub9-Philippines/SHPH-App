import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/call_controller_factory.dart';

void main() {
  test('resolves the deployed other_participant shape', () async {
    final participant = await resolveThreadParticipant(
      'thread-1',
      fallbackUserId: 'fallback',
      loadThread: (_) async => {
        'other_participant': {
          'id': 42,
          'display_name': 'Provider',
          'photo_url': 'https://example.test/avatar.jpg',
        },
      },
    );

    expect(participant.userId, '42');
    expect(participant.name, 'Provider');
    expect(participant.photoUrl, 'https://example.test/avatar.jpg');
  });

  test('supports alternate participant display fields', () async {
    final participant = await resolveThreadParticipant(
      'thread-1',
      fallbackUserId: '9',
      loadThread: (_) async => {
        'other_participant': {
          'name': 'Alternate Name',
          'avatar_url': 'avatar',
        },
      },
    );

    expect(participant.userId, '9');
    expect(participant.name, 'Alternate Name');
    expect(participant.photoUrl, 'avatar');
  });

  test('fails closed to supplied caller identity when lookup fails', () async {
    final participant = await resolveThreadParticipant(
      'thread-1',
      fallbackUserId: '77',
      fallbackName: 'Incoming call',
      loadThread: (_) async => throw StateError('offline'),
    );

    expect(participant.userId, '77');
    expect(participant.name, 'Incoming call');
  });

  test('does not replace a valid fallback with empty API fields', () async {
    final participant = await resolveThreadParticipant(
      'thread-1',
      fallbackUserId: '77',
      fallbackName: 'Caller',
      loadThread: (_) async => {
        'other_participant': {'id': '', 'display_name': ''},
      },
    );

    expect(participant.userId, '77');
    expect(participant.name, 'Caller');
  });
}
