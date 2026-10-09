import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/auth/shph_auth/shph_user_provider.dart';
import 'package:serbisyohubph/pages/chat_page/chat_page_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The participants[] fallback excludes "me" by uid; the deployed thread
    // in these tests belongs to user 24 (client account).
    currentUser = SerbisyoHubPHShphUser({
      'id': 24,
      'email': 'client@shph.com',
      'display_name': 'Client Account',
    });
  });

  group('ChatPageModel other-participant resolution', () {
    // Deploys the shape seen in the field log: participants[] with embedded
    // user objects, other_participant absent. The current user is 24.
    final deployedShape = <String, dynamic>{
      'id': '6ab76dcbbadc117c8b4913d6',
      'thread_type': 'direct',
      'participants': [
        {
          'user': {
            'id': 24,
            'email': 'client@shph.com',
            'display_name': 'Client Account',
            'photo_url': '',
          },
          'role': 'client',
        },
        {
          'user': {
            'id': 7,
            'email': 'provider-ana@serbisyohubph.com',
            'display_name': 'Ana Garcia',
            'photo_url': 'https://example.com/ana.jpg',
          },
          'role': 'provider',
        },
      ],
    };

    test('resolves id/name/photo from participants[] fallback', () {
      final model = ChatPageModel();
      model.threadDetails = deployedShape;

      expect(model.otherParticipantId, '7');
      expect(model.otherParticipantName, 'Ana Garcia');
      expect(model.otherParticipantPhoto, 'https://example.com/ana.jpg');
      expect(model.isDirectThread, isTrue);
    });

    test('prefers other_participant when the serializer provides it', () {
      final model = ChatPageModel();
      model.threadDetails = {
        'thread_type': 'direct',
        'other_participant': {
          'id': 7,
          'display_name': 'Ana Garcia',
          'photo_url': 'ana.jpg',
        },
      };

      expect(model.otherParticipantId, '7');
      expect(model.otherParticipantName, 'Ana Garcia');
    });

    test('handles other_participant as a {user: {...}} wrapper', () {
      final model = ChatPageModel();
      model.threadDetails = {
        'thread_type': 'direct',
        'other_participant': {
          'user': {'id': 7, 'display_name': 'Ana Garcia'},
        },
      };

      expect(model.otherParticipantId, '7');
      expect(model.otherParticipantName, 'Ana Garcia');
    });

    test('startCall throws when no participant can be resolved', () async {
      final model = ChatPageModel();
      model.threadDetails = {'thread_type': 'direct'};

      await expectLater(
        model.startCall(threadId: 't', video: false),
        throwsStateError,
      );
    });
  });
}
