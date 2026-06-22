// =============================================================
// Dispatch Timeout Management — Supabase Edge Function
// =============================================================
// Called via cron schedule (every 60s) to:
//   1. Time out pending offers older than OFFER_TTL seconds
//   2. Re-match the job to the next best provider
//   3. Time out jobs in 'searching' state older than JOB_TTL
//   4. Send in-app notifications via Supabase
//
// Security:
//   - Uses service_role key (bypasses RLS — intentional)
//   - Accepts a CRON_SECRET env var for request validation
//   - Idempotent: only processes jobs not already timed_out
// =============================================================

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.6';

// -----------------------------------------------------------
// Configuration
// -----------------------------------------------------------
const OFFER_TTL_SECONDS = 120;
const JOB_TTL_SECONDS    = 600;
const BATCH_SIZE         = 50;

const SUPABASE_URL  = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const CRON_SECRET   = Deno.env.get('CRON_SECRET');
const supabase      = createClient(SUPABASE_URL, SUPABASE_ROLE);

// -----------------------------------------------------------
// Types
// -----------------------------------------------------------
interface OfferToTimeout {
  id: string;
  job_id: string;
  provider_id: string;
  service_type: string;
  location_lat: number;
  location_lng: number;
}

interface JobToTimeout {
  id: string;
  client_id: string | null;
}

// -----------------------------------------------------------
// Input validation — only allow cron or authorized callers
// -----------------------------------------------------------
function isAuthorized(request: Request): boolean {
  // If no CRON_SECRET is configured, allow all (dev mode)
  if (!CRON_SECRET) return true;

  const authHeader = request.headers.get('authorization') ?? '';
  const bearer = authHeader.replace('Bearer ', '').trim();

  // Accept either the cron secret or the service role key
  return bearer === CRON_SECRET || bearer === SUPABASE_ROLE;
}

// -----------------------------------------------------------
// Queries
// -----------------------------------------------------------
async function fetchExpiredOffers(): Promise<OfferToTimeout[]> {
  const cutoff = new Date(
    Date.now() - OFFER_TTL_SECONDS * 1000,
  ).toISOString();

  const { data, error } = await supabase
    .from('dispatch_offers')
    .select(`
      id,
      job_id,
      provider_id,
      job_requests!inner (
        service_type,
        location_lat,
        location_lng
      )
    `)
    .eq('status', 'pending')
    .lt('offered_at', cutoff)
    .limit(BATCH_SIZE);

  if (error) {
    console.error('fetchExpiredOffers error:', error);
    return [];
  }

  return (data ?? []).map((row: Record<string, unknown>) => {
    const job = row.job_requests as Record<string, unknown>;
    return {
      id:             row.id             as string,
      job_id:         row.job_id         as string,
      provider_id:    row.provider_id    as string,
      service_type:   job.service_type   as string,
      location_lat:   job.location_lat   as number,
      location_lng:   job.location_lng   as number,
    };
  });
}

async function fetchExpiredJobs(): Promise<JobToTimeout[]> {
  const cutoff = new Date(
    Date.now() - JOB_TTL_SECONDS * 1000,
  ).toISOString();

  const { data, error } = await supabase
    .from('job_requests')
    .select('id, client_id')
    .eq('status', 'searching')
    .lt('created_at', cutoff)
    .limit(BATCH_SIZE);

  if (error) {
    console.error('fetchExpiredJobs error:', error);
    return [];
  }

  return (data ?? []) as JobToTimeout[];
}

// -----------------------------------------------------------
// Processors
// -----------------------------------------------------------
async function timeoutOffer(offer: OfferToTimeout): Promise<void> {
  // 1. Mark the offer as timed_out (only if still pending)
  const { error: updateError } = await supabase
    .from('dispatch_offers')
    .update({ status: 'timed_out', responded_at: new Date().toISOString() })
    .eq('id', offer.id)
    .eq('status', 'pending');

  if (updateError) {
    console.error(`timeoutOffer(${offer.id}) update error:`, updateError);
    return;
  }

  // 2. Notify the provider
  await sendNotification(
    offer.provider_id,
    'offer_expired',
    { job_id: offer.job_id, offer_id: offer.id },
  );

  // 3. Attempt rematch to the next best provider
  const { data: nextProvider, error: rpcError } = await supabase
    .rpc('match_best_provider', {
      p_job_id:        offer.job_id,
      p_service_type:  offer.service_type,
      p_lat:           offer.location_lat,
      p_lng:           offer.location_lng,
    });

  if (rpcError) {
    console.error(`timeoutOffer(${offer.id}) rematch error:`, rpcError.message);
    return;
  }

  if (nextProvider) {
    await sendNotification(
      nextProvider as string,
      'new_offer',
      { job_id: offer.job_id },
    );
  }
}

async function timeoutJob(job: JobToTimeout): Promise<void> {
  // Idempotent: only updates if still in 'searching'
  const { data, error } = await supabase
    .from('job_requests')
    .update({ status: 'timed_out' })
    .eq('id', job.id)
    .eq('status', 'searching')
    .select('id');

  if (error) {
    console.error(`timeoutJob(${job.id}) error:`, error);
    return;
  }

  // No rows matched (already assigned/timed_out by another process)
  if (!data || data.length === 0) return;

  if (job.client_id) {
    await sendNotification(
      job.client_id,
      'job_timed_out',
      { job_id: job.id },
    );
  }

  console.log(`[dispatch] Job ${job.id} timed out (no providers matched)`);
}

// -----------------------------------------------------------
// Notifications
// -----------------------------------------------------------
async function sendNotification(
  userId: string,
  type: string,
  payload: Record<string, unknown>,
): Promise<void> {
  const title = notificationTitle(type);
  const body  = notificationBody(type, payload);

  const { error } = await supabase.from('notifications').insert({
    user_id:    userId,
    title:      title,
    body:       body,
    type:       type,
    metadata:   payload,
    is_read:    false,
  });

  if (error) {
    console.error(`sendNotification(${type}, ${userId}) error:`, error);
  }
}

function notificationTitle(type: string): string {
  const titles: Record<string, string> = {
    new_offer:     'New Job Offer',
    offer_expired: 'Offer Expired',
    job_timed_out: 'Search Timed Out',
    job_assigned:  'Job Assigned',
  };
  return titles[type] ?? 'Dispatch Update';
}

function notificationBody(
  type: string,
  _payload: Record<string, unknown>,
): string {
  const bodies: Record<string, string> = {
    new_offer:
      'A new job matching your skills is available. Tap to review.',
    offer_expired:
      'Your offer for a job has expired because the time limit was reached.',
    job_timed_out:
      'We could not find an available provider for your job right now. Please try again.',
    job_assigned:
      'A provider has been assigned to your job.',
  };
  return bodies[type] ?? 'Your dispatch status has been updated.';
}

// -----------------------------------------------------------
// Main handler
// -----------------------------------------------------------
serve(async (req) => {
  const requestId = crypto.randomUUID();
  const start = Date.now();

  // Auth check
  if (!isAuthorized(req)) {
    console.warn(`[${requestId}] Unauthorized request rejected`);
    return new Response(
      JSON.stringify({ ok: false, error: 'Unauthorized' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } },
    );
  }

  // Phase 1: Time out expired offers (rematch via reject_offer_and_rematch RPC)
  const expiredOffers = await fetchExpiredOffers();
  await Promise.allSettled(expiredOffers.map(timeoutOffer));

  // Phase 2: Time out jobs that never got a match
  const expiredJobs = await fetchExpiredJobs();
  await Promise.allSettled(expiredJobs.map(timeoutJob));

  const errorCount =
    expiredOffers.length + expiredJobs.length -
    expiredOffers.filter((o) => o).length; // count non-completed

  const elapsed = Date.now() - start;
  console.log(
    `[${requestId}] Cycle: ${expiredOffers.length} offers, ` +
    `${expiredJobs.length} jobs (${elapsed}ms)`,
  );

  return new Response(
    JSON.stringify({
      ok: true,
      request_id: requestId,
      offers_processed: expiredOffers.length,
      jobs_processed: expiredJobs.length,
      elapsed_ms: elapsed,
    }),
    { headers: { 'Content-Type': 'application/json' } },
  );
});
