-- =============================================================
-- Provider Payouts — Database Schema
-- =============================================================
-- Run this in the Supabase SQL Editor.
-- All statements are idempotent (safe to run repeatedly).
-- =============================================================

-- ENUM: payout_status
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payout_status') THEN
    CREATE TYPE payout_status AS ENUM (
      'pending', 'approved', 'completed', 'rejected'
    );
  END IF;
END $$;

-- PAYOUTS table
CREATE TABLE IF NOT EXISTS public.payouts (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount          NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  status          payout_status DEFAULT 'pending',
  payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
  requested_at    TIMESTAMPTZ DEFAULT now() NOT NULL,
  approved_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  rejected_at     TIMESTAMPTZ,
  rejection_reason TEXT,
  note            TEXT,
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payouts_provider
  ON public.payouts (provider_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payouts_status
  ON public.payouts (status, created_at DESC);

-- ROW LEVEL SECURITY
ALTER TABLE public.payouts ENABLE ROW LEVEL SECURITY;

-- Providers can read their own payouts
DROP POLICY IF EXISTS payouts_provider_select ON public.payouts;
CREATE POLICY payouts_provider_select ON public.payouts
  FOR SELECT
  USING (provider_id = auth.uid());

-- Providers can create payout requests
DROP POLICY IF EXISTS payouts_provider_insert ON public.payouts;
CREATE POLICY payouts_provider_insert ON public.payouts
  FOR INSERT
  WITH CHECK (provider_id = auth.uid());

-- Providers can cancel (reject) their own pending payouts
DROP POLICY IF EXISTS payouts_provider_update ON public.payouts;
CREATE POLICY payouts_provider_update ON public.payouts
  FOR UPDATE
  USING (provider_id = auth.uid())
  WITH CHECK (provider_id = auth.uid());

-- Admins can read all payouts (assuming role check via profiles)
-- This policy allows reads for users with role 'admin' in profiles
DROP POLICY IF EXISTS payouts_admin_select ON public.payouts;
CREATE POLICY payouts_admin_select ON public.payouts
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Admins can update payout status
DROP POLICY IF EXISTS payouts_admin_update ON public.payouts;
CREATE POLICY payouts_admin_update ON public.payouts
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
