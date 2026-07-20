-- =============================================================
-- Disputes — Database Schema
-- =============================================================
-- Run in Supabase SQL Editor (idempotent)
-- =============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dispute_status') THEN
    CREATE TYPE dispute_status AS ENUM (
      'open', 'under_review', 'resolved', 'closed', 'rejected'
    );
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.disputes (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id      UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  raised_by       UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  provider_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reason          TEXT NOT NULL,
  description     TEXT,
  status          dispute_status DEFAULT 'open',
  resolution      TEXT,
  resolved_by     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_disputes_raised_by ON public.disputes (raised_by, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_disputes_provider ON public.disputes (provider_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON public.disputes (status, created_at DESC);

-- DISPUTE EVIDENCE table
CREATE TABLE IF NOT EXISTS public.dispute_evidence (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dispute_id      UUID REFERENCES public.disputes(id) ON DELETE CASCADE NOT NULL,
  uploaded_by     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  file_url        TEXT NOT NULL,
  file_type       TEXT,
  description     TEXT,
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dispute_evidence_dispute ON public.dispute_evidence (dispute_id, created_at DESC);

-- RLS
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_evidence ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS disputes_user_select ON public.disputes;
CREATE POLICY disputes_user_select ON public.disputes
  FOR SELECT USING (raised_by = auth.uid() OR provider_id = auth.uid());

DROP POLICY IF EXISTS disputes_user_insert ON public.disputes;
CREATE POLICY disputes_user_insert ON public.disputes
  FOR INSERT WITH CHECK (raised_by = auth.uid());

DROP POLICY IF EXISTS disputes_user_update ON public.disputes;
CREATE POLICY disputes_user_update ON public.disputes
  FOR UPDATE USING (raised_by = auth.uid() OR provider_id = auth.uid());

DROP POLICY IF EXISTS disputes_admin_all ON public.disputes;
CREATE POLICY disputes_admin_all ON public.disputes
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS evidence_user_select ON public.dispute_evidence;
CREATE POLICY evidence_user_select ON public.dispute_evidence
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.disputes WHERE id = dispute_id AND (raised_by = auth.uid() OR provider_id = auth.uid()))
  );

DROP POLICY IF EXISTS evidence_user_insert ON public.dispute_evidence;
CREATE POLICY evidence_user_insert ON public.dispute_evidence
  FOR INSERT WITH CHECK (uploaded_by = auth.uid());

-- =============================================================
-- Notification Preferences — Database Schema
-- =============================================================

CREATE TABLE IF NOT EXISTS public.notification_preferences (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  push_enabled    BOOLEAN DEFAULT true,
  email_enabled   BOOLEAN DEFAULT true,
  sms_enabled     BOOLEAN DEFAULT false,
  booking_updates BOOLEAN DEFAULT true,
  payment_updates BOOLEAN DEFAULT true,
  promo_offers    BOOLEAN DEFAULT false,
  provider_alerts BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notif_prefs_owner_select ON public.notification_preferences;
CREATE POLICY notif_prefs_owner_select ON public.notification_preferences
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS notif_prefs_owner_insert ON public.notification_preferences;
CREATE POLICY notif_prefs_owner_insert ON public.notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS notif_prefs_owner_update ON public.notification_preferences;
CREATE POLICY notif_prefs_owner_update ON public.notification_preferences
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
