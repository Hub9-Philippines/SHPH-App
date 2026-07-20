---
description: Port the wallet top-up and balance system from the web app to Flutter mobile
---

# Skill: Port Wallet System

Port the digital wallet system (balance, top-up via PayMongo, transaction history) from the web app to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/wallet/`)

The web app has a `wallet/` Django app (seen in the directory listing) with:
- `WalletTopUp` model — tracks top-up requests with PayMongo integration
- `confirm_and_credit()` method — credits wallet balance when PayMongo payment succeeds
- Wallet top-up shares PayMongo webhook handler with booking payments (`_route_wallet_topup()` in `payments/views.py:710-731`)
- Status flow: PENDING → COMPLETED / FAILED

### Frontend (Vue — `shph-app/src/`)

- `views/profile/WalletPage.vue` (9KB) — Wallet dashboard:
  - Current balance display
  - Top-up button (opens PayMongo payment modal)
  - Transaction history (top-ups, spending)
  - Payment method selector for top-up

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_wallet_tables.sql`:

```sql
-- Wallet balances table (one row per user)
CREATE TABLE IF NOT EXISTS wallet_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  balance DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Wallet transactions table
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- top_up, payment, refund, payout
  amount DECIMAL(10,2) NOT NULL,
  description TEXT DEFAULT '',
  paymongo_intent_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, completed, failed
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_wallet_tx_user ON wallet_transactions(user_id);
CREATE INDEX idx_wallet_tx_type ON wallet_transactions(type);
CREATE INDEX idx_wallet_tx_status ON wallet_transactions(status);

ALTER TABLE wallet_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wallet" ON wallet_balances
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own transactions" ON wallet_transactions
  FOR SELECT USING (auth.uid() = user_id);
```

### 2. Supabase RPC for Atomic Top-Up

```sql
CREATE OR REPLACE FUNCTION credit_wallet(
  p_amount DECIMAL(10,2),
  p_transaction_id UUID,
  p_description TEXT DEFAULT ''
) RETURNS void AS $$
BEGIN
  -- Insert or update wallet balance
  INSERT INTO wallet_balances (user_id, balance)
    VALUES (auth.uid(), p_amount)
    ON CONFLICT (user_id) DO UPDATE
    SET balance = wallet_balances.balance + p_amount,
        updated_at = now();
  
  -- Mark transaction as completed
  UPDATE wallet_transactions
    SET status = 'completed'
    WHERE id = p_transaction_id AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3. Flutter Service

Create `lib/services/wallet_service.dart`:

Key methods:
- `getBalance()` → Get user's wallet balance (create row with 0 if not exists)
- `getTransactions({page, pageSize})` → Paginated transaction history
- `topUp(amount, paymentMethodId)` → Create PayMongo intent, insert pending transaction
- `confirmTopUp(transactionId, paymongoIntentId)` → Verify PayMongo, credit wallet via RPC
- `payFromWallet(amount, bookingId)` → Deduct from wallet for booking payment

### 4. Flutter UI

Create `lib/pages/wallet/wallet_widget.dart`:
- Balance card (large display with gradient background)
- "Top Up" button → opens top-up modal
- Transaction history list (paginated, pull-to-refresh)
- Each transaction: type icon, description, amount (+/-), date, status

Create `lib/pages/wallet/top_up_modal_widget.dart`:
- Amount input (quick select: ₱100, ₱500, ₱1000, custom)
- Payment method selector (from saved payment methods)
- "Top Up" button → creates PayMongo intent → confirms → credits wallet

### 5. Integration with Payments

- Wallet top-up uses the same PayMongo integration as booking payments
- PayMongo webhook handler should route wallet top-up intents (like web app's `_route_wallet_topup()`)
- Wallet can be used as a payment method for bookings (deduct from balance)

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/wallet/` | Wallet Django app (models, views) |
| `shph-api/src/shph/payments/views.py:710-731` | `_route_wallet_topup()` in PayMongo webhook |
| `shph-app/src/views/profile/WalletPage.vue` | Wallet UI (9KB) |
| `shph-app/src/services/api.ts` | walletApi calls |

## Key Differences for Flutter

- Web uses Django ORM for wallet balance; mobile should use Supabase RPC for atomic updates
- Web shares PayMongo webhook with payments; mobile backend should do the same
- Web wallet is a separate Django app; mobile should be a separate service but share payment infrastructure
- Web uses `confirm_and_credit()` method; mobile should use Supabase RPC `credit_wallet()`
- Wallet is optional — can be implemented after payments system is in place
