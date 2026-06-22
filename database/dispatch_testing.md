# Dispatch Engine — Testing Guide

> **Production-readiness notes:**
> - RLS policies are enabled — test with appropriate `auth.uid()` context
> - Advisory locks prevent race conditions — test concurrent calls
> - All `dispatch_offers.status` values validated via CHECK constraint
> - `cancel_job()` RPC handles offer rejection + cancellation atomically

## 1. Schema Test

**Goal:** Verify that `job_requests` and `dispatch_offers` tables work correctly.

### Run in Supabase SQL Editor:

```sql
-- Verify tables exist
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('job_requests', 'dispatch_offers');

-- Verify the RPC functions exist
SELECT proname, prosrc
FROM pg_proc
WHERE proname IN ('match_best_provider', 'reject_offer_and_rematch', 'accept_offer', 'cancel_job')
  AND pronamespace = 'public'::regnamespace;

-- Verify the trigger exists
SELECT tgname, tgrelid::regclass
FROM pg_trigger
WHERE tgname = 'trg_job_request_match';
```

**Expected:** All tables, functions, and triggers should exist.

### Test automatic matching:

```sql
-- 1. Ensure you have a provider profile with location + service_category
UPDATE profiles
SET
  role = 'provider',
  service_category = 'plumbing',
  is_available = true,
  location = ST_SetSRID(ST_MakePoint(120.9842, 14.5995), 4326)::geography
WHERE id = '<PROVIDER_UUID>';

-- 2. Insert a job request (trigger will auto-match)
INSERT INTO job_requests (client_id, service_type, location_lat, location_lng, requested_time)
VALUES ('<CLIENT_UUID>', 'plumbing', 14.5995, 120.9842, now());

-- 3. Check the results after a few seconds
SELECT jr.id, jr.status, jr.assigned_provider_id,
       do2.id AS offer_id, do2.provider_id, do2.status AS offer_status
FROM job_requests jr
LEFT JOIN dispatch_offers do2 ON do2.job_id = jr.id
ORDER BY jr.created_at DESC
LIMIT 5;
```

**Expected:** The job_request status should become `offered` or `assigned`, and a `dispatch_offers` row should exist with `status = 'pending'`.

---

## 2. Function Test

**Goal:** Manually call `match_best_provider`.

```sql
SELECT match_best_provider(
  '<JOB_UUID>',
  'plumbing',
  14.5995,
  120.9842
);
```

**Expected:** Returns a provider UUID if a match was found, or NULL if none available.

### Test offer rejection + rematch:

```sql
SELECT reject_offer_and_rematch(
  '<JOB_UUID>',
  '<PROVIDER_UUID>'
);
```

**Expected:** Original offer status changes to `rejected`, a new offer may be created.

### Test offer acceptance:

```sql
SELECT accept_offer(
  '<JOB_UUID>',
  '<PROVIDER_UUID>'
);
```

**Expected:** Returns `true`. The offer status becomes `accepted`, other pending offers become `rejected`, job status becomes `assigned`.

### Test job cancellation:

```sql
SELECT cancel_job('<JOB_UUID>');
```

**Expected:** Returns `true`. All pending offers become `rejected`, job status becomes `cancelled`.

### Verify stale offer acceptance is rejected:

```sql
-- After cancel_job, trying accept_offer should return false
SELECT accept_offer('<JOB_UUID>', '<PROVIDER_UUID>');
```

**Expected:** Returns `false` because the job is already `cancelled`.

---

## 3. Edge Function Test

**Goal:** Simulate a timeout scenario.

### Setup:

1. Insert a job request that intentionally has no matching providers (use a non-existent `service_type`)
2. Wait for the Edge Function to run (cron runs every 60s) OR invoke manually:

```sh
curl -X POST https://<PROJECT_REF>.supabase.co/functions/v1/dispatch_timeout_management \
  -H "Authorization: Bearer <ANON_KEY>"
```

**Expected Response:**
```json
{
  "ok": true,
  "offers_processed": 0,
  "jobs_processed": 1,
  "elapsed_ms": 150
}
```

### Timeout an offer:

1. Insert a job with a matching provider
2. Wait for the offer to be created (auto-trigger)
3. Do NOT accept the offer
4. After 120 seconds (default `OFFER_TTL_SECONDS`), the Edge Function should:
   - Mark the offer as `timed_out`
   - Call `match_best_provider` for a rematch
   - Create a notification for the provider

### Verify notifications:

```sql
SELECT * FROM notifications
WHERE type IN ('new_offer', 'offer_expired', 'job_timed_out')
ORDER BY created_at DESC
LIMIT 10;
```

---

## 4. Client Integration Test

**Goal:** Ensure Dart client interacts with the dispatch system correctly.

### Prerequisites:
- Supabase local or remote instance with the schema applied
- At least one provider profile with `location`, `service_category`, and `is_available = true`
- Flutter app running on a device/emulator

### Test Client Job Creation:

```dart
import '/services/dispatch/dispatch_service.dart';

final dispatch = DispatchService.instance;

// Create a job
final jobId = await dispatch.createJob(
  serviceType: 'plumbing',
  latitude: 14.5995,
  longitude: 120.9842,
);
print('Job created: $jobId');
```

### Test Real-time Client Updates:

```dart
// Watch for provider assignment
dispatch.watchClientJob(jobId).listen((view) {
  if (view == null) return;
  print('Status: ${view.job.status}');
  if (view.providerProfile != null) {
    print('Assigned to: ${view.providerProfile!['display_name']}');
  }
});
```

### Test Provider Offer Stream:

```dart
// Provider side — watch incoming offers
dispatch.watchProviderOffers().listen((offers) {
  for (final offer in offers) {
    print('New offer for job: ${offer.job.serviceType}');
    print('Client: ${offer.clientDisplayName}');
  }
});

// Accept an offer
final accepted = await dispatch.acceptOffer(jobId);
print('Offer accepted: $accepted');
```

### Test TM Flow Integration:

```dart
import '/pages/tm_flow/tm_controller.dart';
import '/pages/dispatch/dispatch_repository.dart';

// Use the DubaiDispatchTMRepository instead of the mock
final controller = TMFlowController(
  selectedService: selectedService,
  repository: DispatchTMRepository(),
);
controller.startBroadcast();
```

---

## 5. Performance Validation

Check that the spatial index is being used:

```sql
EXPLAIN ANALYZE
SELECT p.id
FROM profiles p
WHERE p.service_category = 'plumbing'
  AND p.is_available = true
  AND p.location IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM dispatch_offers d
    WHERE d.job_id = '<JOB_UUID>' AND d.provider_id = p.id
  )
ORDER BY p.location <-> ST_SetSRID(ST_MakePoint(120.9842, 14.5995), 4326)::geography ASC
LIMIT 1;
```

**Expected:** The query should use an `Index Scan` on `idx_provider_location`.

---

## 6. Edge Cases to Verify

| Scenario | Expected Behaviour |
|---|---|
| No providers match | Job stays `searching`, eventually timed_out by Edge Function |
| Provider rejects offer | Offer marked `rejected`, next provider matched automatically |
| All providers reject | Job stays `offered`, eventually timed_out |
| Client cancels during search | Job becomes `cancelled`, all pending offers become `rejected` |
| Provider accepts after timeout | `accept_offer` returns false, job stays `timed_out` |
| Concurrent matching (same provider, two jobs) | Advisory lock + UNIQUE constraint prevent duplicate offers |
| Concurrent accept (two providers, same job) | First `accept_offer` wins; second returns false |
| RLS: provider reads job_request without offer | `job_requests_provider_select` policy blocks it |
| Edge Function: job already assigned | `timeoutJob` skips due to `status != 'searching'` filter |
| Edge Function: offer already timed_out | `timeoutOffer` skips due to `status != 'pending'` filter |
| Duplicate job insertion | No duplicate check — handled by client idempotency |
| Provider is offline/unavailable | `is_available = false` excludes them from matching |
| Location is NULL | Excluded from matching (`location IS NOT NULL` in query) |
