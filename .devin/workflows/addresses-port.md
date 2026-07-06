---
description: Port the full addresses CRUD system from the web app to Flutter mobile
---

# Skill: Port Addresses System

Port the complete saved-addresses management system (create, read, update, delete, set default) from the web app to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/profiles/`)

**Address Model** (in `profiles/models.py`):
- `user` FK, `label` (Home, Work, Other), `full_address` (text), `latitude`, `longitude`
- `is_default` boolean (one default per user)
- `city`, `province`, `barangay` fields
- `created_at`, `updated_at`

**Views**:
- `GET/POST /api/profiles/addresses/` — List + create addresses
- `GET/PUT/DELETE /api/profiles/addresses/<pk>/` — Retrieve, update, delete
- `POST /api/profiles/addresses/<pk>/default/` — Set as default

### Frontend (Vue — `shph-app/src/`)

- `views/profile/AddressesPage.vue` (6KB) — List of saved addresses with:
  - Label badge (Home/Work/Other)
  - Full address text
  - Default badge
  - Edit / Delete actions
  - "Add Address" button

- `views/profile/AddressFormPage.vue` (20KB) — Address form with:
  - Label selector (Home, Work, Other)
  - Google Places autocomplete for address search
  - Map with draggable pin (Leaflet)
  - Latitude/longitude auto-filled from pin
  - City, province, barangay fields (populated from PSGC API)
  - Save / Cancel

- `composables/useAddressPicker.ts` — Address picker composable
- `services/location.ts` (8KB) — GPS, geocoding, PSGC API integration

---

## What the Mobile App Needs

### 1. Supabase Table (SQL Migration)

The mobile app already has an `addresses` table (referenced in `database_schema.sql` and `supabase_addresses_table.sql`). Verify it has these fields:

```sql
-- If not already present, add these columns:
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS label TEXT DEFAULT 'Other';
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS is_default BOOLEAN DEFAULT false;
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS province TEXT;
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS barangay TEXT;
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS latitude DECIMAL(9,6);
ALTER TABLE addresses ADD COLUMN IF NOT EXISTS longitude DECIMAL(9,6);

-- Ensure RLS
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own addresses" ON addresses
  FOR ALL USING (auth.uid() = user_id);
```

### 2. Flutter Service

Create `lib/services/addresses_service.dart`:

Key methods:
- `getAddresses()` → List user's saved addresses, default first
- `addAddress({label, fullAddress, latitude, longitude, city, province, barangay})` → Insert
- `updateAddress(id, {label, fullAddress, ...})` → Update
- `deleteAddress(id)` → Delete
- `setDefault(id)` → Set one as default (unset others — use Supabase RPC or two queries)
- `getDefaultAddress()` → Get the user's default address

**Set default pattern**:
```dart
Future<void> setDefault(String addressId) async {
  // Unset all defaults first
  await supabase.from('addresses')
    .update({'is_default': false})
    .eq('user_id', userId)
    .eq('is_default', true);
  // Set new default
  await supabase.from('addresses')
    .update({'is_default': true})
    .eq('id', addressId)
    .eq('user_id', userId);
}
```

### 3. Flutter UI

Pages to create:
- `lib/pages/addresses/addresses_list_widget.dart` — Address list:
  - Each address card: label badge, full address, default indicator
  - Edit / Delete swipe actions or buttons
  - "Add Address" FAB
  - Empty state with illustration

- `lib/pages/addresses/address_form_widget.dart` — Address form:
  - Label selector (Home, Work, Other) — segmented control or dropdown
  - Google Places search field (use `google_places_flutter` or `google_maps_flutter`)
  - Google Maps with draggable pin
  - Auto-fill lat/lng from pin position
  - City, province, barangay text fields (auto-filled from reverse geocoding)
  - "Set as default" toggle
  - Save / Cancel buttons

### 4. Google Maps Integration

The mobile app already uses Google Maps (`google_maps_flutter` package). Reuse for:
- Address picker map with draggable marker
- Reverse geocoding to auto-fill address text
- Google Places autocomplete for address search

### 5. Integration Points

- Add "My Addresses" menu item in profile/settings page
- Use saved addresses in booking flow (pre-fill location selection)
- Use default address for recommendations (location-based scoring)
- Use default address for on-demand dispatch (client location)

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/profiles/models.py` | Address model |
| `shph-api/src/shph/profiles/views.py` | Address CRUD endpoints |
| `shph-app/src/views/profile/AddressesPage.vue` | Address list UI (6KB) |
| `shph-app/src/views/profile/AddressFormPage.vue` | Address form UI (20KB) |
| `shph-app/src/composables/useAddressPicker.ts` | Address picker composable |
| `shph-app/src/services/location.ts` | GPS, geocoding, PSGC (8KB) |

## Current Mobile App State

- `addresses` table exists in Supabase (see `supabase_addresses_table.sql`)
- Only 1 direct Supabase query for address update (per `api_gaps.md`)
- No addresses list page exists
- No address form page exists
- Google Maps is already integrated for booking flow
- PSGC API is already used for location selection

## Key Differences for Flutter

- Web uses Leaflet maps; mobile uses Google Maps (already integrated)
- Web uses Google Places JS API; mobile should use `google_places_flutter` or Places API via Dio
- Web has PSGC API integration in `location.ts`; mobile already has PSGC in `lib/services/`
- Web uses Vue composables; mobile should use StatefulWidget + service class
- Web form is 20KB (complex); mobile can simplify with Google Maps native picker
