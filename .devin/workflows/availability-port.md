---
description: Port the provider availability scheduling system from the web app to Flutter mobile
---

# Skill: Port Provider Availability System

Port the weekly availability schedule system that lets providers set their working hours per day of the week.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/services/models.py:467-500`)

**Model**:
```python
class ProviderAvailability(models.Model):
    class DayOfWeek(models.IntegerChoices):
        MONDAY = 0, "Monday"
        TUESDAY = 1, "Tuesday"
        WEDNESDAY = 2, "Wednesday"
        THURSDAY = 3, "Thursday"
        FRIDAY = 4, "Friday"
        SATURDAY = 5, "Saturday"
        SUNDAY = 6, "Sunday"

    provider = models.ForeignKey(User, on_delete=models.CASCADE, related_name="availability_slots")
    day_of_week = models.IntegerField(choices=DayOfWeek.choices)
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_active = models.BooleanField(default=True)
```

- Multiple slots per day allowed (e.g., morning + afternoon)
- Ordered by day_of_week, start_time
- Indexed on (provider, day_of_week)

### Frontend (Vue — `shph-app/src/`)

- `views/provider/ProviderAvailabilityPage.vue` (12.8KB) — Weekly schedule UI:
  - 7-day grid (Mon-Sun)
  - Add time slot per day (start/end time pickers)
  - Toggle slot active/inactive
  - Delete slot
  - Save all changes
- `composables/useAvailability.ts` — Availability composable for CRUD
- `services/api.ts` — `availabilityApi` with list, create, update, delete

---

## What the Mobile App Needs

### 1. Supabase Table (SQL Migration)

Create `database/create_provider_availability_table.sql`:

```sql
CREATE TABLE IF NOT EXISTS provider_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL, -- 0=Monday, 1=Tuesday, ..., 6=Sunday
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_availability_provider_day ON provider_availability(provider_id, day_of_week);

ALTER TABLE provider_availability ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view own availability" ON provider_availability
  FOR SELECT USING (auth.uid() = provider_id);
CREATE POLICY "Providers can manage own availability" ON provider_availability
  FOR ALL USING (auth.uid() = provider_id);
```

### 2. Flutter Service

Create `lib/services/availability_service.dart`:

Key methods:
- `getAvailability()` → Get all availability slots for current provider, ordered by day_of_week + start_time
- `addSlot({dayOfWeek, startTime, endTime})` → Insert new slot
- `updateSlot(id, {startTime, endTime, isActive})` → Update existing slot
- `deleteSlot(id)` → Delete slot
- `isAvailableOn(DateTime dateTime)` → Check if provider is available at a specific datetime (matches day_of_week + time range)
- `getAvailableDays()` → List of days with at least one active slot

### 3. Flutter UI

Create `lib/pages/availability/availability_widget.dart`:
- 7-day expandable list (Monday-Sunday)
- Each day shows existing time slots as chips/cards
- "Add slot" button per day → opens time range picker (start_time, end_time)
- Each slot has toggle (active/inactive) and delete button
- Save button persists all changes
- Visual indicator for days with no availability

### 4. Integration Points

- Add "Availability" menu item in pro dashboard / profile
- Use availability data when provider accepts/rejects bookings (show conflict warning)
- Use availability in booking flow (show only available time slots to clients)
- Show availability status on provider profile page

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/services/models.py:467-500` | ProviderAvailability model |
| `shph-app/src/views/provider/ProviderAvailabilityPage.vue` | Availability UI (12.8KB) |
| `shph-app/src/composables/useAvailability.ts` | Availability composable |
| `shph-app/src/services/api.ts` | availabilityApi calls |

## Key Differences for Flutter

- Web uses Django TimeField; mobile uses `TimeOfDay` in Dart
- Web uses integer day_of_week (0=Monday); mobile should use same convention
- Web allows multiple slots per day; mobile should do the same
- Web has is_active toggle per slot; mobile should include this
- No complex business logic — straightforward CRUD
