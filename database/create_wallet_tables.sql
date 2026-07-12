-- =============================================================
-- Wallet — Database Schema (SHPH-150 equivalent for mobile)
-- =============================================================
-- Run in Supabase SQL Editor (idempotent)
-- =============================================================

-- ENUM: wallet_transaction_type
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'wallet_transaction_type') THEN
    CREATE TYPE wallet_transaction_type AS ENUM (
      'top_up', 'payment', 'payout', 'refund', 'reversal', 'adjustment'
    );
  END IF;
END $$;

-- WALLETS table (one per user)
CREATE TABLE IF NOT EXISTS public.wallets (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  balance         NUMERIC(12, 2) DEFAULT 0.00 NOT NULL CHECK (balance >= 0),
  currency        TEXT DEFAULT 'PHP',
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_wallets_user ON public.wallets (user_id);

-- WALLET_TRANSACTIONS table
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  wallet_id       UUID REFERENCES public.wallets(id) ON DELETE CASCADE NOT NULL,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type            wallet_transaction_type NOT NULL,
  amount          NUMERIC(12, 2) NOT NULL,
  balance_after   NUMERIC(12, 2),
  description     TEXT,
  reference_id    TEXT,
  booking_id      UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_wallet_tx_wallet ON public.wallet_transactions (wallet_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_user ON public.wallet_transactions (user_id, created_at DESC);

-- ROW LEVEL SECURITY
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- Users can read their own wallet
DROP POLICY IF EXISTS wallets_owner_select ON public.wallets;
CREATE POLICY wallets_owner_select ON public.wallets
  FOR SELECT USING (user_id = auth.uid());

-- Users can insert their own wallet
DROP POLICY IF EXISTS wallets_owner_insert ON public.wallets;
CREATE POLICY wallets_owner_insert ON public.wallets
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Users can update their own wallet (balance changes via RPC)
DROP POLICY IF EXISTS wallets_owner_update ON public.wallets;
CREATE POLICY wallets_owner_update ON public.wallets
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can read their own transactions
DROP POLICY IF EXISTS wallet_tx_owner_select ON public.wallet_transactions;
CREATE POLICY wallet_tx_owner_select ON public.wallet_transactions
  FOR SELECT USING (user_id = auth.uid());

-- Users can insert their own transactions
DROP POLICY IF EXISTS wallet_tx_owner_insert ON public.wallet_transactions;
CREATE POLICY wallet_tx_owner_insert ON public.wallet_transactions
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- FUNCTION: top_up_wallet (atomic balance update + transaction log)
CREATE OR REPLACE FUNCTION top_up_wallet(
  p_user_id UUID,
  p_amount NUMERIC(12, 2),
  p_description TEXT DEFAULT NULL,
  p_reference_id TEXT DEFAULT NULL
) RETURNS public.wallet_transactions
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wallet public.wallets;
  v_tx public.wallet_transactions;
BEGIN
  -- Get or create wallet
  SELECT * INTO v_wallet FROM public.wallets WHERE user_id = p_user_id;
  IF NOT FOUND THEN
    INSERT INTO public.wallets (user_id, balance) VALUES (p_user_id, 0)
    RETURNING * INTO v_wallet;
  END IF;

  -- Update balance
  UPDATE public.wallets
    SET balance = balance + p_amount, updated_at = now()
    WHERE user_id = p_user_id
    RETURNING * INTO v_wallet;

  -- Insert transaction
  INSERT INTO public.wallet_transactions (
    wallet_id, user_id, type, amount, balance_after, description, reference_id
  ) VALUES (
    v_wallet.id, p_user_id, 'top_up', p_amount, v_wallet.balance, p_description, p_reference_id
  )
  RETURNING * INTO v_tx;

  RETURN v_tx;
END;
$$;

-- FUNCTION: pay_from_wallet (atomic deduction)
CREATE OR REPLACE FUNCTION pay_from_wallet(
  p_user_id UUID,
  p_amount NUMERIC(12, 2),
  p_booking_id UUID DEFAULT NULL,
  p_description TEXT DEFAULT NULL
) RETURNS public.wallet_transactions
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wallet public.wallets;
  v_tx public.wallet_transactions;
BEGIN
  SELECT * INTO v_wallet FROM public.wallets WHERE user_id = p_user_id;
  IF NOT FOUND OR v_wallet.balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient wallet balance';
  END IF;

  UPDATE public.wallets
    SET balance = balance - p_amount, updated_at = now()
    WHERE user_id = p_user_id
    RETURNING * INTO v_wallet;

  INSERT INTO public.wallet_transactions (
    wallet_id, user_id, type, amount, balance_after, booking_id, description
  ) VALUES (
    v_wallet.id, p_user_id, 'payment', -p_amount, v_wallet.balance, p_booking_id, p_description
  )
  RETURNING * INTO v_tx;

  RETURN v_tx;
END;
$$;
