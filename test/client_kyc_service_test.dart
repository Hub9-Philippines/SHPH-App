import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/api/resources/kyc_api.dart';
import 'package:serbisyohubph/services/client_kyc_service.dart';

void main() {
  group('ClientKycService', () {
    test('submit payload uses the customer role and web field names', () {
      final service = ClientKycService();
      final payload = service.buildSubmitPayload(
        idFrontBytes: const [1, 2],
        idFrontName: 'id_front.jpg',
        idBackBytes: const [3, 4],
        idBackName: 'id_back.jpg',
        selfieBytes: const [5, 6],
        selfieName: 'selfie.jpg',
        challengeNonce: 'nonce-abc',
        livenessMetadata: const {'challenge_plan': ['blink']},
        livenessScore: 0.98,
      );

      expect(payload.submitterRole, 'customer');
      expect(payload.idFront?.fileName, 'id_front.jpg');
      expect(payload.idBack?.fileName, 'id_back.jpg');
      expect(payload.selfie?.fileName, 'selfie.jpg');
      expect(payload.challengeNonce, 'nonce-abc');
      expect(payload.livenessScore, 0.98);

      final form = ShphKycApi.instance.buildFormData(payload);
      final keys = form.fields.map((e) => e.key).toSet();
      final fileKeys = form.files.map((e) => e.key).toSet();
      expect(keys, contains('submitter_role'));
      expect(keys, contains('challenge_nonce'));
      expect(keys, contains('liveness_metadata'));
      expect(keys, contains('liveness_score'));
      expect(fileKeys, contains('id_front'));
      expect(fileKeys, contains('id_back'));
      expect(fileKeys, contains('selfie'));
      expect(
        form.fields.firstWhere((e) => e.key == 'submitter_role').value,
        'customer',
      );
      // Provider-only slots are never present on the client payload.
      expect(fileKeys, isNot(contains('nbi_clearance')));
      expect(fileKeys, isNot(contains('portfolio')));
      expect(fileKeys, isNot(contains('resume')));
    });

    test('submit payload without liveness proof omits those fields', () {
      final service = ClientKycService();
      final payload = service.buildSubmitPayload(
        idFrontBytes: const [1],
        idFrontName: 'f.jpg',
        idBackBytes: const [2],
        idBackName: 'b.jpg',
        selfieBytes: const [3],
        selfieName: 's.jpg',
      );

      final form = ShphKycApi.instance.buildFormData(payload);
      final keys = form.fields.map((e) => e.key).toSet();
      expect(keys, isNot(contains('challenge_nonce')));
      expect(keys, isNot(contains('liveness_metadata')));
      expect(keys, isNot(contains('liveness_score')));
      expect(form.files.map((e) => e.key), containsAll(['id_front', 'id_back', 'selfie']));
      expect(
        form.fields.firstWhere((e) => e.key == 'submitter_role').value,
        'customer',
      );
    });
  });
}