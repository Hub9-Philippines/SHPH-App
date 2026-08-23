import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/api/resources/kyc_api.dart';
import 'package:serbisyohubph/services/kyc_hub_service.dart';

void main() {
  group('ShphKycApi.buildFormData', () {
    test('submits web-parity field names for the full provider package', () {
      final api = ShphKycApi.instance;
      final formData = api.buildFormData(
        const KycSubmitPayload(
          submitterRole: 'provider',
          idFront: KycDocumentFile([1], 'id_front.jpg'),
          idBack: KycDocumentFile([2], 'id_back.jpg'),
          selfie: KycDocumentFile([3], 'selfie.jpg'),
          nbiClearance: KycDocumentFile([4], 'nbi.jpg'),
          portfolio: KycDocumentFile([5], 'portfolio.pdf'),
          resume: KycDocumentFile([6], 'resume.pdf'),
          challengeNonce: 'nonce-123',
          livenessMetadata: {'smile': true},
          livenessScore: 1,
        ),
      );

      final fileFieldNames =
          formData.files.map((e) => e.key).toSet();
      final plainFieldNames =
          formData.fields.map((e) => e.key).toSet();
      final allNames = fileFieldNames.union(plainFieldNames);

      // Every web `submitKycDocs` field must be present.
      expect(
        allNames,
        containsAll(<String>[
          'submitter_role',
          'id_front',
          'id_back',
          'selfie',
          'nbi_clearance',
          'portfolio',
          'resume',
          'challenge_nonce',
          'liveness_metadata',
          'liveness_score',
        ]),
      );

      // File fields land in the files list with their upload filenames.
      expect(formData.files, hasLength(6));
      expect(formData.files.map((e) => e.key), containsAll(<String>[
        'id_front',
        'id_back',
        'selfie',
        'nbi_clearance',
        'portfolio',
        'resume',
      ]));
      final idFront = formData.files.firstWhere((e) => e.key == 'id_front');
      expect(idFront.value.filename, 'id_front.jpg');

      // Scalar fields keep their exact values.
      expect(plainFieldNames, contains('submitter_role'));
      final submitterRole =
          formData.fields.firstWhere((e) => e.key == 'submitter_role');
      expect(submitterRole.value, 'provider');
      final nonce =
          formData.fields.firstWhere((e) => e.key == 'challenge_nonce');
      expect(nonce.value, 'nonce-123');
      final score =
          formData.fields.firstWhere((e) => e.key == 'liveness_score');
      expect(score.value, '1.0');
      final metadata =
          formData.fields.firstWhere((e) => e.key == 'liveness_metadata');
      expect(metadata.value, '{"smile":true}');
    });

    test('omits provider-only docs and liveness fields when absent', () {
      final api = ShphKycApi.instance;
      final formData = api.buildFormData(
        const KycSubmitPayload(
          submitterRole: 'customer',
          idFront: KycDocumentFile([1], 'id_front.jpg'),
          idBack: KycDocumentFile([2], 'id_back.jpg'),
        ),
      );

      final fileFieldNames = formData.files.map((e) => e.key).toSet();
      final plainFieldNames = formData.fields.map((e) => e.key).toSet();

      expect(fileFieldNames, containsAll(<String>['id_front', 'id_back']));
      expect(fileFieldNames, isNot(contains('nbi_clearance')));
      expect(fileFieldNames, isNot(contains('portfolio')));
      expect(fileFieldNames, isNot(contains('resume')));
      expect(fileFieldNames, isNot(contains('selfie')));
      expect(plainFieldNames, isNot(contains('challenge_nonce')));
      expect(plainFieldNames, isNot(contains('liveness_metadata')));
      expect(plainFieldNames, isNot(contains('liveness_score')));
    });
  });

  group('KycHubService.normalizeStatus', () {
    test('maps historical vocabulary onto the web status set', () {
      expect(KycHubService.normalizeStatus('approved'), 'approved');
      expect(KycHubService.normalizeStatus('verified'), 'approved');
      expect(KycHubService.normalizeStatus('pending'), 'pending');
      expect(KycHubService.normalizeStatus('under_review'), 'pending');
      expect(KycHubService.normalizeStatus('reviewing'), 'pending');
      expect(KycHubService.normalizeStatus('rejected'), 'rejected');
      expect(KycHubService.normalizeStatus('not_started'), 'not_submitted');
      expect(KycHubService.normalizeStatus('unverified'), 'not_submitted');
      expect(KycHubService.normalizeStatus(null), 'not_submitted');
    });
  });
}
