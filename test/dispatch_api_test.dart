import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/dispatch/dispatch_models.dart';

void main() {
  group('DispatchStatus', () {
    test('fromDb parses valid statuses', () {
      expect(DispatchStatus.fromDb('searching'), DispatchStatus.searching);
      expect(DispatchStatus.fromDb('offered'), DispatchStatus.offered);
      expect(DispatchStatus.fromDb('assigned'), DispatchStatus.assigned);
      expect(DispatchStatus.fromDb('completed'), DispatchStatus.completed);
      expect(DispatchStatus.fromDb('timedOut'), DispatchStatus.timedOut);
      expect(DispatchStatus.fromDb('cancelled'), DispatchStatus.cancelled);
    });

    test('fromDb falls back to searching for unknown status', () {
      expect(DispatchStatus.fromDb('unknown'), DispatchStatus.searching);
      expect(DispatchStatus.fromDb(''), DispatchStatus.searching);
    });

    test('dbValue round-trips', () {
      for (final status in DispatchStatus.values) {
        expect(DispatchStatus.fromDb(status.dbValue), status);
      }
    });
  });

  group('OfferStatus', () {
    test('fromDb parses valid statuses', () {
      expect(OfferStatus.fromDb('pending'), OfferStatus.pending);
      expect(OfferStatus.fromDb('accepted'), OfferStatus.accepted);
      expect(OfferStatus.fromDb('rejected'), OfferStatus.rejected);
      expect(OfferStatus.fromDb('timedOut'), OfferStatus.timedOut);
    });

    test('fromDb falls back to pending for unknown status', () {
      expect(OfferStatus.fromDb('unknown'), OfferStatus.pending);
      expect(OfferStatus.fromDb(''), OfferStatus.pending);
    });

    test('dbValue round-trips', () {
      for (final status in OfferStatus.values) {
        expect(OfferStatus.fromDb(status.dbValue), status);
      }
    });
  });

  group('DispatchJobRequest.fromJson', () {
    test('parses full job request response', () {
      final json = {
        'id': 'job-42',
        'client_id': 'client-1',
        'service_type': 'Plumbing',
        'location_lat': 14.5995,
        'location_lng': 120.9842,
        'requested_time': '2026-07-06T12:00:00Z',
        'status': 'searching',
        'booking_id': null,
        'created_at': '2026-07-06T10:00:00Z',
        'assigned_provider_id': null,
      };

      final job = DispatchJobRequest.fromJson(json);

      expect(job.id, 'job-42');
      expect(job.clientId, 'client-1');
      expect(job.serviceType, 'Plumbing');
      expect(job.locationLat, 14.5995);
      expect(job.locationLng, 120.9842);
      expect(job.status, DispatchStatus.searching);
      expect(job.bookingId, isNull);
      expect(job.assignedProviderId, isNull);
    });

    test('parses assigned job with booking_id', () {
      final json = {
        'id': 'abc123',
        'client_id': 'client-2',
        'service_type': 'Electrical',
        'location_lat': 14.5,
        'location_lng': 121.0,
        'requested_time': '2026-07-06T14:00:00Z',
        'status': 'assigned',
        'booking_id': 'booking-xyz',
        'created_at': '2026-07-06T10:00:00Z',
        'assigned_provider_id': 'provider-1',
      };

      final job = DispatchJobRequest.fromJson(json);

      expect(job.id, 'abc123');
      expect(job.serviceType, 'Electrical');
      expect(job.status, DispatchStatus.assigned);
      expect(job.bookingId, 'booking-xyz');
      expect(job.assignedProviderId, 'provider-1');
    });

    test('parses timedOut job', () {
      final json = {
        'id': 'job-99',
        'client_id': 'client-3',
        'service_type': 'Cleaning',
        'location_lat': 0,
        'location_lng': 0,
        'requested_time': '2026-07-06T12:00:00Z',
        'status': 'timedOut',
        'created_at': '2026-07-06T10:00:00Z',
      };

      final job = DispatchJobRequest.fromJson(json);

      expect(job.status, DispatchStatus.timedOut);
      expect(job.serviceType, 'Cleaning');
    });
  });

  group('DispatchOffer.fromJson', () {
    test('parses pending offer', () {
      final json = {
        'id': 'offer-1',
        'job_id': 'job-42',
        'provider_id': 'provider-7',
        'status': 'pending',
        'offered_at': '2026-07-06T10:05:00Z',
      };

      final offer = DispatchOffer.fromJson(json);

      expect(offer.id, 'offer-1');
      expect(offer.jobId, 'job-42');
      expect(offer.providerId, 'provider-7');
      expect(offer.status, OfferStatus.pending);
      expect(offer.offeredAt, DateTime.parse('2026-07-06T10:05:00Z'));
    });

    test('parses accepted offer with responded_at', () {
      final json = {
        'id': 'offer-2',
        'job_id': 'job-15',
        'provider_id': 'provider-3',
        'status': 'accepted',
        'offered_at': '2026-07-06T10:10:00Z',
        'responded_at': '2026-07-06T10:15:00Z',
      };

      final offer = DispatchOffer.fromJson(json);

      expect(offer.id, 'offer-2');
      expect(offer.jobId, 'job-15');
      expect(offer.providerId, 'provider-3');
      expect(offer.status, OfferStatus.accepted);
      expect(offer.respondedAt, DateTime.parse('2026-07-06T10:15:00Z'));
    });

    test('parses rejected offer', () {
      final json = {
        'id': 'offer-3',
        'job_id': 'job-abc',
        'provider_id': 'provider-xyz',
        'status': 'rejected',
        'offered_at': '2026-07-06T10:15:00Z',
      };

      final offer = DispatchOffer.fromJson(json);

      expect(offer.id, 'offer-3');
      expect(offer.jobId, 'job-abc');
      expect(offer.providerId, 'provider-xyz');
      expect(offer.status, OfferStatus.rejected);
    });

    test('parses timedOut offer', () {
      final json = {
        'id': 'offer-4',
        'job_id': 'job-99',
        'provider_id': 'provider-5',
        'status': 'timedOut',
        'offered_at': '2026-07-06T10:00:00Z',
      };

      final offer = DispatchOffer.fromJson(json);

      expect(offer.status, OfferStatus.timedOut);
      expect(offer.respondedAt, isNull);
    });
  });

  group('DispatchJobRequest.toJson', () {
    test('produces valid JSON map', () {
      final job = DispatchJobRequest(
        id: 'job-42',
        serviceType: 'Plumbing',
        locationLat: 14.5995,
        locationLng: 120.9842,
        requestedTime: DateTime.parse('2026-07-06T12:00:00Z'),
        status: DispatchStatus.searching,
        createdAt: DateTime.parse('2026-07-06T10:00:00Z'),
      );

      final json = job.toJson();

      expect(json['id'], 'job-42');
      expect(json['service_type'], 'Plumbing');
      expect(json['status'], 'searching');
      expect(json['location_lat'], 14.5995);
      expect(json['location_lng'], 120.9842);
    });
  });

  group('DispatchOffer.toJson', () {
    test('produces valid JSON map', () {
      final offer = DispatchOffer(
        id: 'offer-1',
        jobId: 'job-42',
        providerId: 'provider-7',
        status: OfferStatus.pending,
        offeredAt: DateTime.parse('2026-07-06T10:05:00Z'),
      );

      final json = offer.toJson();

      expect(json['id'], 'offer-1');
      expect(json['job_id'], 'job-42');
      expect(json['provider_id'], 'provider-7');
      expect(json['status'], 'pending');
    });
  });
}
