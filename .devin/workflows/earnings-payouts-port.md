---
description: Port the provider earnings & payouts system from the web app to Flutter mobile
---

# Skill: Port Earnings & Payouts System

Port the full earnings tracking and payout request system from the web app (`shph-api/earnings/`, `shph-app/src/views/provider/EarningsPage.vue`) to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/earnings/`)

**Models** (`earnings/models.py`):
- `EarningsTransaction` — provider FK, booking FK (nullable), amount, type (credit/debit/payout), description, created_at
- `PayoutRequest` — provider FK, payment_method FK, amount, status (pending/processing/completed/failed), created_at, processed_at

**Views** (`earnings/views.py`):
- `GET/POST /api/earnings/summary/` — Returns: total_earned, today, this_week, this_month, pending, available
- `GET/POST /api/earnings/transactions/` — Paginated transaction history
- `POST /api/earnings/payout/` — Request payout (atomic balance check with row lock, creates PayoutRequest + matching DEBIT EarningsTransaction)
- `GET/POST /api/earnings/payouts/` — List provider's payout request history
- `GET/POST /api/earnings/admin/payouts/` — Admin: list all payouts with status filter
- `POST /api/earnings/admin/payouts/<pk>/<action>/` — Admin: approve/complete/reject payout (with row lock, rejection creates reversal CREDIT)

**Key Business Logic**:
- Balance = credits - payouts - pending_payouts
- Payout request is atomic: locks user row, checks available balance, creates PayoutRequest + DEBIT transaction
- Admin payout actions: approve (pending→processing), complete (processing→completed), reject (pending/processing→failed + reversal CREDIT)
- Earnings are credited automatically when a payment is confirmed (see `payments/views.py:_credit_provider_earnings`)
- Idempotent earnings crediting via `earnings_credited` flag on Payment

### Frontend (Vue — `shph-app/src/`)

- `views/provider/EarningsPage.vue` (14KB) — Earnings dashboard with summary cards, transaction list, payout request modal
- `views/provider/ProviderDashboardPage.vue` — Earnings tab in provider dashboard
- `components/analytics/EarningsChart.vue` — Chart.js earnings visualization
- `services/api.ts` — `earningsApi` with getSummary, getTransactions, requestPayout, getPayouts

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_earnings_tables.sql`:

```sql
-- Earnings transactions table
CREATE TABLE IF NOT EXISTS earnings_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  type TEXT NOT NULL, -- credit, debit, payout
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Payout requests table
CREATE TABLE IF NOT EXISTS payout_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  payment_method_id UUID REFERENCES payment_methods(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, processing, completed, failed
  created_at TIMESTAMPTZ DEFAULT now(),
  processed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_earnings_provider ON earnings_transactions(provider_id);
CREATE INDEX idx_earnings_type ON earnings_transactions(type);
CREATE INDEX idx_earnings_provider_type ON earnings_transactions(provider_id, type);
CREATE INDEX idx_payouts_provider ON payout_requests(provider_id);
CREATE INDEX idx_payouts_status ON payout_requests(status);

-- RLS
ALTER TABLE earnings_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payout_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view own earnings" ON earnings_transactions
  FOR SELECT USING (auth.uid() = provider_id);

CREATE POLICY "Providers can view own payouts" ON payout_requests
  FOR SELECT USING (auth.uid() = provider_id);

CREATE POLICY "Providers can create own payouts" ON payout_requests
  FOR INSERT WITH CHECK (auth.uid() = provider_id);
```

### 2. Flutter Service

Create `lib/services/earnings_service.dart`:

Key methods:
- `getEarningsSummary()` → Query earnings_transactions (aggregate credits today/this_week/this_month/total), query pending payouts
- `getTransactions({page, pageSize})` → Paginated transaction history from Supabase
- `requestPayout(amount, paymentMethodId)` → Validate balance, insert payout_request + debit transaction (use Supabase RPC for atomicity)
- `getPayoutHistory()` → List provider's payout requests
- `getAvailableBalance()` → credits - payouts - pending_payouts

**Balance calculation** (replicate `_provider_balance()`):
```dart
Future<double> getAvailableBalance() async {
  final credits = await supabase.from('earnings_transactions')
    .select('amount').eq('provider_id', userId).eq('type', 'credit');
  final payouts = await supabase.from('earnings_transactions')
    .select('amount').eq('provider_id', userId).eq('type', 'payout');
  final pending = await supabase.from('payout_requests')
    .select('amount').eq('provider_id', userId)
    .inFilter('status', ['pending', 'processing']);
  // available = sum(credits) - sum(payouts) - sum(pending)
}
```

### 3. Flutter UI

Pages to create:
- `lib/pages/earnings/earnings_widget.dart` — Earnings dashboard:
  - Summary cards: Total Earned, Today, This Week, This Month
  - Available balance card with "Request Payout" button
  - Pending payouts display
  - Transaction history list (paginated, pull-to-refresh)
- `lib/pages/payout_request/payout_request_widget.dart` — Payout modal:
  - Amount input (validates against available balance)
  - Payment method selector
  - Confirmation with summary

### 4. Supabase RPC for Atomic Payout

Create a Postgres function for atomic balance check + payout creation:

```sql
CREATE OR REPLACE FUNCTION request_payout(
  p_amount DECIMAL(10,2),
  p_payment_method_id UUID
) RETURNS JSON AS $$
DECLARE
  v_available DECIMAL(10,2);
  v_credits DECIMAL(10,2);
  v_payouts DECIMAL(10,2);
  v_pending DECIMAL(10,2);
  v_payout_id UUID;
BEGIN
  -- Lock the provider row
  SELECT * FROM profiles WHERE id = auth.uid() FOR UPDATE;
  
  -- Calculate balance
  SELECT COALESCE(SUM(amount), 0) INTO v_credits
    FROM earnings_transactions WHERE provider_id = auth.uid() AND type = 'credit';
  SELECT COALESCE(SUM(amount), 0) INTO v_payouts
    FROM earnings_transactions WHERE provider_id = auth.uid() AND type = 'payout';
  SELECT COALESCE(SUM(amount), 0) INTO v_pending
    FROM payout_requests WHERE provider_id = auth.uid() AND status IN ('pending', 'processing');
  
  v_available := v_credits - v_payouts - v_pending;
  
  IF p_amount > v_available THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;
  
  INSERT INTO payout_requests (provider_id, payment_method_id, amount, status)
    VALUES (auth.uid(), p_payment_method_id, p_amount, 'pending')
    RETURNING id INTO v_payout_id;
  
  INSERT INTO earnings_transactions (provider_id, amount, type, description)
    VALUES (auth.uid(), p_amount, 'payout', 'Payout request #' || v_payout_id);
  
  RETURN json_build_object('payout_id', v_payout_id, 'status', 'pending');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 5. Integration with Payments

- Earnings are credited when a payment is confirmed (see `payments-port.md`)
- When implementing payments, the payment confirmation flow should insert a `credit` earnings_transaction
- When a payment is refunded, insert a `debit` earnings_transaction

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/earnings/models.py` | EarningsTransaction & PayoutRequest models |
| `shph-api/src/shph/earnings/views.py` | All earnings endpoints (433 lines) |
| `shph-api/src/shph/earnings/serializers.py` | DRF serializers |
| `shph-api/src/shph/payments/views.py:106-132` | `_credit_provider_earnings()` — how earnings are created |
| `shph-app/src/views/provider/EarningsPage.vue` | Earnings dashboard UI (14KB) |
| `shph-app/src/components/analytics/EarningsChart.vue` | Chart.js earnings chart |
| `shph-app/src/services/api.ts` | earningsApi axios calls |

## Current Mobile App State

- Pro dashboard has an "Earnings" tab (`lib/main/pro_dashboard/`) but shows **hardcoded data**
- No `earnings_transactions` or `payout_requests` tables exist in Supabase
- No earnings service exists in `lib/services/`
- `home_model.dart:34` has hardcoded notification count — similar pattern of missing real data

## Key Differences for Flutter

- Web uses Django ORM aggregates for balance calculation; mobile should use Supabase queries or RPC
- Web uses `select_for_update()` for atomic payout; mobile should use Supabase RPC function
- Web uses Chart.js for earnings visualization; mobile should use `fl_chart` or `syncfusion_flutter_charts`
- Web admin payout management is in Wagtail; mobile doesn't need admin panel (use web for admin)
