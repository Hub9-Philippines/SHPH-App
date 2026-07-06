---
description: Port the booking disputes system from the web app to Flutter mobile
---

# Skill: Port Disputes System

Port the full dispute filing, evidence upload, and resolution system from the web app to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/disputes/`)

**Models** (`disputes/models.py`):
- `Dispute` — booking FK, raised_by FK, reason (service_not_rendered/poor_quality/overcharged/no_show/other), description, evidence (image upload), status (open/under_review/resolved/closed), admin_notes, resolved_at

**Views** (`disputes/views.py`):
- `GET/POST /api/disputes/` — List user's disputes + raise new dispute (ListCreateAPIView)
- `POST /api/disputes/<pk>/evidence/` — Upload evidence image (multipart, validates file type)
- `GET/POST /api/disputes/booking/<booking_id>/` — List disputes for a specific booking
- `GET/POST /api/disputes/list/` — POST alternative to list user's disputes
- `GET/POST /api/disputes/admin/` — Admin: list all disputes with status filter
- `POST /api/disputes/admin/<pk>/<action>/` — Admin: review/resolve/close dispute with admin_notes

**Dispute Status Flow**:
```
open → under_review → resolved → closed
```

**Dispute Reasons**:
- `service_not_rendered` — Service Not Rendered
- `poor_quality` — Poor Quality of Service
- `overcharged` — Overcharged
- `no_show` — Provider No-Show
- `other` — Other

### Frontend (Vue — `shph-app/src/`)

- `views/profile/DisputesPage.vue` (7KB) — List user's disputes with status badges
- `views/services/BookingDetailPage.vue` — "Raise Dispute" button on completed bookings
- `services/api.ts` — `disputesApi` with list, create, uploadEvidence, getByBooking

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_disputes_table.sql`:

```sql
CREATE TABLE IF NOT EXISTS disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  raised_by UUID REFERENCES profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL, -- service_not_rendered, poor_quality, overcharged, no_show, other
  description TEXT DEFAULT '',
  evidence_url TEXT, -- Supabase Storage URL for uploaded evidence
  status TEXT NOT NULL DEFAULT 'open', -- open, under_review, resolved, closed
  admin_notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_disputes_booking ON disputes(booking_id);
CREATE INDEX idx_disputes_raised_by ON disputes(raised_by);
CREATE INDEX idx_disputes_status ON disputes(status);
CREATE INDEX idx_disputes_booking_status ON disputes(booking_id, status);

ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own disputes" ON disputes
  FOR SELECT USING (
    auth.uid() = raised_by OR auth.uid() IN (
      SELECT pro_id FROM bookings WHERE id = disputes.booking_id
    )
  );

CREATE POLICY "Users can create own disputes" ON disputes
  FOR INSERT WITH CHECK (auth.uid() = raised_by);

CREATE POLICY "Users can update own disputes" ON disputes
  FOR UPDATE USING (auth.uid() = raised_by);
```

### 2. Flutter Service

Create `lib/services/disputes_service.dart`:

Key methods:
- `getDisputes()` → List user's disputes from Supabase, ordered by created_at desc
- `getDisputesByBooking(bookingId)` → List disputes for a specific booking
- `createDispute({bookingId, reason, description})` → Insert new dispute with status 'open'
- `uploadEvidence(disputeId, File imageFile)` → Upload to Supabase Storage, update dispute.evidence_url
- `getDisputeStatus(disputeId)` → Get single dispute status

### 3. Flutter UI

Pages to create:
- `lib/pages/disputes/disputes_list_widget.dart` — List of user's disputes with status badges
- `lib/pages/disputes/dispute_detail_widget.dart` — Dispute details with evidence image, status timeline
- `lib/pages/disputes/raise_dispute_widget.dart` — Form to raise a dispute:
  - Reason dropdown (5 options)
  - Description text field
  - Evidence photo upload (image_picker → Supabase Storage)
  - Submit button

### 4. Integration Points

- Add "Raise Dispute" button on `booking_details_widget.dart` for completed bookings
- Add "Disputes" menu item in profile/settings page
- Show dispute status on booking details if a dispute exists
- Booking status should change to 'disputed' when a dispute is raised (add to bookings table if not exists)

### 5. Supabase Storage

- Create storage bucket: `disputes`
- Upload evidence images to `disputes/{dispute_id}/{timestamp}.jpg`
- Set bucket policy to allow authenticated users to read/write their own dispute evidence

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/disputes/models.py` | Dispute model (68 lines) |
| `shph-api/src/shph/disputes/views.py` | All dispute endpoints (279 lines) |
| `shph-api/src/shph/disputes/serializers.py` | DRF serializer |
| `shph-app/src/views/profile/DisputesPage.vue` | Disputes list UI (7KB) |
| `shph-app/src/views/services/BookingDetailPage.vue` | Raise dispute button |
| `shph-app/src/services/api.ts` | disputesApi axios calls |

## Key Differences for Flutter

- Web uses Django ImageField for evidence upload; mobile should use Supabase Storage + image_picker
- Web has admin dispute management in Wagtail; mobile doesn't need admin panel
- Web validates file uploads server-side (`validate_upload_file`); mobile should validate file type/size before upload
- Web uses DRF ListCreateAPIView; mobile should use direct Supabase queries
- Evidence upload: web uses multipart form; mobile uploads to Supabase Storage then stores URL
