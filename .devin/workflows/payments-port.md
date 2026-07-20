---
description: Port the PayMongo payments system from the web app to Flutter mobile
---

# Skill: Port Payments System (PayMongo)

Port the full payment integration from the web app (`shph-api/payments/`, `shph-app/src/views/profile/PaymentMethodsPage.vue`) to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/payments/`)

**Models** (`payments/models.py`):
- `Payment` — OneToOne with booking, tracks status (pending/confirmed/failed/refunded), PayMongo intent IDs, amount, tip_amount, earnings_credited flag, confirmed_at, refunded_at, refund_reason
- `Voucher` — Discount codes (flat or percentage), max_uses, uses_count, expires_at, min_order_amount, compute_discount() method

**Views** (`payments/views.py`):
- `POST /api/payments/create-intent/` — Creates PayMongo PaymentIntent, returns client_key. Handles voucher validation & discount. Falls back to mock when PayMongo not configured
- `POST /api/payments/confirm/` — Verifies PayMongo intent status, confirms payment, credits provider earnings, sends notification + WS push
- `GET/POST /api/payments/booking/<booking_id>/` — Get payment status for a booking
- `POST /api/payments/webhook/` — PayMongo webhook handler (payment.paid, payment.failed). Verifies signature
- `POST /api/payments/tip/<booking_id>/` — Add tip to confirmed payment (idempotent)
- `POST /api/payments/voucher/validate/` — Validate voucher code without applying
- `POST /api/payments/refund/<payment_id>/` — Admin refund, debits provider earnings, notifies client

**Key Business Logic**:
- Amount is converted to centavos (×100) for PayMongo
- Payment methods: card, gcash, paymaya, grab_pay
- 3D Secure required for cards
- Voucher double-discount guard: checks if discount was already applied at booking creation
- Idempotent earnings crediting via `earnings_credited` flag + row lock
- Cancellation fee: ₱100 flat if confirmed past 2-min grace window

**PaymentMethod Model** (in `users/models.py`):
- `PaymentMethod` — user FK, type (card/gcash/paymaya/grab_pay), provider, last4, is_default

### Frontend (Vue — `shph-app/src/`)

- `views/profile/PaymentMethodsPage.vue` — List/add/remove payment methods
- `views/services/BookingDetailPage.vue` — Pay-now modal with voucher code input
- `views/provider/EarningsPage.vue` — Provider sees payment confirmations
- `stores/services.ts` — Booking + payment state
- `services/api.ts` — `paymentsApi` with createIntent, confirmPayment, getBookingPayment, addTip

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_payments_tables.sql`:

```sql
-- Payment methods table
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL DEFAULT 'card', -- card, gcash, paymaya, grab_pay
  provider TEXT,
  last4 TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE UNIQUE,
  payment_method_id UUID REFERENCES payment_methods(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, confirmed, failed, refunded
  intent_id TEXT,
  client_key TEXT,
  paymongo_intent_id TEXT,
  tip_amount DECIMAL(8,2),
  earnings_credited BOOLEAN DEFAULT false,
  confirmed_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  refund_reason TEXT DEFAULT '',
  refunded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Vouchers table
CREATE TABLE IF NOT EXISTS vouchers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  discount_type TEXT NOT NULL DEFAULT 'flat', -- flat, percentage
  discount_value DECIMAL(8,2) NOT NULL,
  min_order_amount DECIMAL(10,2),
  max_uses INTEGER,
  uses_count INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS policies
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE vouchers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own payment methods" ON payment_methods
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view payments for their bookings" ON payments
  FOR SELECT USING (
    auth.uid() IN (
      SELECT client_id FROM bookings WHERE id = payments.booking_id
      UNION
      SELECT pro_id FROM bookings WHERE id = payments.booking_id
    )
  );

CREATE POLICY "Vouchers are readable by all" ON vouchers
  FOR SELECT USING (is_active = true);
```

### 2. Flutter Service

Create `lib/services/payments_service.dart`:

Key methods to implement:
- `createPaymentIntent(bookingId, paymentMethodId, {voucherCode})` → POST to backend or call PayMongo SDK
- `confirmPayment(intentId, paymentMethodId)` → Verify and confirm
- `getBookingPayment(bookingId)` → Get payment status
- `addTip(bookingId, amount)` → Add tip to confirmed payment
- `validateVoucher(code, orderAmount)` → Validate without applying
- `getPaymentMethods()` → List user's saved payment methods
- `addPaymentMethod(type, provider, last4)` → Add new payment method
- `deletePaymentMethod(id)` → Remove payment method
- `setDefaultPaymentMethod(id)` → Set default

### 3. Flutter UI

Pages to create:
- `lib/pages/payment_methods/payment_methods_widget.dart` — List/add/remove payment methods
- `lib/pages/payment_modal/payment_modal_widget.dart` — Pay-now modal (amount, voucher input, payment method selector)
- `lib/pages/tip_modal/tip_modal_widget.dart` — Add tip after service completion

### 4. SHPH API Contract

Verify or request these routes in the deployed SHPH API:
- `POST /api/payments/create-intent` — Create PayMongo intent
- `POST /api/payments/confirm` — Confirm payment
- `GET /api/payments/booking/:bookingId` — Get payment status
- `POST /api/payments/webhook` — PayMongo webhook handler
- `POST /api/payments/tip/:bookingId` — Add tip
- `POST /api/payments/voucher/validate` — Validate voucher
- `GET/POST/DELETE /api/payments/methods` — Payment method CRUD

### 5. PayMongo Integration

- Keep PayMongo SDK usage and secrets in the deployed SHPH API
- Amount in centavos (×100)
- Payment methods allowed: card, gcash, paymaya, grab_pay
- 3D Secure: `request_three_d_secure: "any"` for cards
- Mock fallback for dev: `PAYMONGO_MOCK_ALLOWED=true`

### 6. State Integration

- Add `paymentMethods` list to `FFAppState` (`lib/app_state.dart`)
- Add `selectedPaymentMethodId` to app state
- Add payment status to booking details model

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/payments/models.py` | Payment & Voucher models |
| `shph-api/src/shph/payments/views.py` | All payment endpoints (1026 lines) |
| `shph-api/src/shph/payments/serializers.py` | DRF serializers |
| `shph-api/src/shph/users/models.py` | PaymentMethod model |
| `shph-app/src/views/profile/PaymentMethodsPage.vue` | Payment methods UI |
| `shph-app/src/views/services/BookingDetailPage.vue` | Pay-now modal |
| `shph-app/src/services/api.ts` | paymentsApi axios calls |
| `shph-app/src/stores/services.ts` | Payment state in Pinia |

## Key Differences for Flutter

- Web uses PayMongo Python SDK; mobile backend should use `paymongo` npm package
- Web stores payment methods in Django ORM; mobile should use Supabase `payment_methods` table
- Web uses Django Channels for WS push on payment confirmed; mobile uses Supabase Realtime
- Web frontend uses axios; mobile uses Dio or direct Supabase queries
- Booking ID: web uses string (ObjectId), mobile uses UUID — ensure PayMongo metadata uses correct ID format
