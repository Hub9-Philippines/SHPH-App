import 'dart:async';

import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

import 'dispatch_models.dart';

class DispatchService {
  DispatchService._();
  static final DispatchService instance = DispatchService._();

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<String> createJob({
    required String serviceType,
    required double latitude,
    required double longitude,
    String? bookingId,
    DateTime? requestedTime,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('User must be logged in to create a job request.');
    }

    final payload = {
      'client_id': userId,
      'service_type': serviceType,
      'location_lat': latitude,
      'location_lng': longitude,
      'requested_time': (requestedTime ?? DateTime.now()).toIso8601String(),
      'status': 'searching',
      if (bookingId != null) 'booking_id': bookingId,
    };

    try {
      final response = await _supabase
          .from('job_requests')
          .insert(payload)
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      LoggingService.error(
        'Failed to create job request: $e',
        tag: 'DispatchService',
      );
      rethrow;
    }
  }

  Future<bool> cancelJob(String jobId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return false;
    }

    try {
      final result = await _supabase.rpc('cancel_job', params: {
        'p_job_id': jobId,
      });
      return result == true;
    } catch (e) {
      LoggingService.error(
        'Failed to cancel job: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Stream<ClientJobView?> watchClientJob(String jobId) => _supabase
      .from('job_requests')
      .stream(primaryKey: ['id'])
      .eq('id', jobId)
      .asyncMap((rows) async {
        if (rows.isEmpty) {
          return null;
        }
        final job = DispatchJobRequest.fromJson(rows.first);

        DispatchOffer? offer;
        Map<String, dynamic>? profile;

        final providerId = job.assignedProviderId;
        if (providerId != null) {
          final offerResp = await _supabase
              .from('dispatch_offers')
              .select()
              .eq('job_id', jobId)
              .eq('provider_id', providerId)
              .maybeSingle();
          if (offerResp != null) {
            offer = DispatchOffer.fromJson(offerResp);
          }

          final profileResp = await _supabase
              .from('profiles')
              .select('id, display_name, photo_url, skill_profession')
              .eq('id', providerId)
              .maybeSingle();
          if (profileResp != null) {
            profile = profileResp;
          }
        }

        return ClientJobView(job: job, offer: offer, providerProfile: profile);
      });

  Stream<List<ProviderOfferView>> watchProviderOffers() {
    final userId = _currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }

    return _supabase
        .from('dispatch_offers')
        .stream(primaryKey: ['id'])
        .eq('provider_id', userId)
        .asyncMap((rows) async {
          final views = <ProviderOfferView>[];
          for (final row in rows) {
            final status = row['status'] as String?;
            if (status != 'pending' && status != 'accepted') {
              continue;
            }

            final offer = DispatchOffer.fromJson(row);
            final jobResp = await _supabase
                .from('job_requests')
                .select('*, profiles!job_requests_client_id_fkey(display_name)')
                .eq('id', offer.jobId)
                .single();
            final job = DispatchJobRequest.fromJson(jobResp);
            final clientName = (jobResp['profiles']
                as Map<String, dynamic>?)?['display_name'] as String?;

            views.add(ProviderOfferView(
              offer: offer,
              job: job,
              clientDisplayName: clientName,
            ));
          }
          return views;
        });
  }

  Future<bool> acceptOffer(String jobId) async {
    final providerId = _currentUserId;
    if (providerId == null) {
      return false;
    }

    try {
      final result = await _supabase.rpc('accept_offer', params: {
        'p_job_id': jobId,
        'p_provider_id': providerId,
      });
      return result == true;
    } catch (e) {
      LoggingService.error(
        'Failed to accept offer: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Future<bool> rejectOffer(String jobId) async {
    final providerId = _currentUserId;
    if (providerId == null) {
      return false;
    }

    try {
      final result = await _supabase.rpc('reject_offer_and_rematch', params: {
        'p_job_id': jobId,
        'p_provider_id': providerId,
      });
      return result != null;
    } catch (e) {
      LoggingService.error(
        'Failed to reject offer: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Future<bool> completeJob(String jobId) async {
    try {
      await _supabase
          .from('job_requests')
          .update({'status': 'completed'})
          .eq('id', jobId);
      return true;
    } catch (e) {
      LoggingService.error(
        'Failed to complete job: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Future<DispatchJobRequest?> getJobById(String jobId) async {
    try {
      final response = await _supabase
          .from('job_requests')
          .select()
          .eq('id', jobId)
          .maybeSingle();
      if (response == null) {
        return null;
      }
      return DispatchJobRequest.fromJson(response);
    } catch (e) {
      LoggingService.error(
        'Failed to fetch job: $e',
        tag: 'DispatchService',
      );
      return null;
    }
  }

  Future<DispatchOffer?> getOffer(String jobId, String providerId) async {
    try {
      final response = await _supabase
          .from('dispatch_offers')
          .select()
          .eq('job_id', jobId)
          .eq('provider_id', providerId)
          .maybeSingle();
      if (response == null) {
        return null;
      }
      return DispatchOffer.fromJson(response);
    } catch (e) {
      LoggingService.error(
        'Failed to fetch offer: $e',
        tag: 'DispatchService',
      );
      return null;
    }
  }
}
