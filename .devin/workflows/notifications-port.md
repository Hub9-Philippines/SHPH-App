---
description: Port the full notification system from the web app to Flutter mobile
---

# Skill: Port Notifications System

Port the complete notification system — in-app notifications, push notifications, notification preferences, and smart scheduling — from the web app to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/notifications/`)

**Models** (`notifications/models.py` — 332 lines):

1. `Notification` — Full polymorphic notification model:
   - `user` (recipient), `from_user` (sender)
   - `content_type` + `object_id` + `content_object` (GenericForeignKey — links to any model)
   - `type` (booking/message/service/system)
   - `title`, `message`, `verb`, `redirect_url`, `icon`
   - `read`, `seen` flags (synced: read→seen, seen→read)
   - `data` (JSON), `info` (JSON), `fcm` (JSON for push payload)
   - `send_user_notif()` — pushes to WebSocket channel
   - `serialize()` — flat dict for WS/push payloads
   - Auto-populates `info` cache with user details on save

2. `NotificationSchedule` — Recurring notification schedules:
   - frequency (daily/weekly/monthly/custom)
   - scheduled_time, scheduled_date, days_of_week (JSON array)
   - is_active, last_sent

3. `NotificationPreference` — Per-user notification settings:
   - Channel toggles: email_enabled, push_enabled, sms_enabled
   - Per-type toggles: booking, message, service, system, payments, recommendations, promotions
   - Quiet hours (DND): quiet_hours_start, quiet_hours_end, quiet_allow_urgent
   - Smart scheduling: smart_scheduling, activity_based, frequency_optimization
   - Volume: max_per_day, grouping, auto_dismiss (never/1h/6h/1d/3d/1w)

4. `UserPattern` — ML-learned user behavior patterns:
   - pattern_type, pattern_data (JSON), confidence_score

**Views** (`notifications/views.py` — 559 lines):
- `GET/POST /api/notifications/` — List notifications (paginated, optional `?unread=true` filter)
- `PATCH /api/notifications/<pk>/read/` — Mark as read
- `POST /api/notifications/read/all/` — Mark all as read
- `GET/POST /api/notifications/unread/count/` — Unread count
- `DELETE /api/notifications/<pk>/` — Delete notification
- `GET/PUT/PATCH /api/notifications/preferences/` — Get/update notification preferences
- `GET/POST /api/notifications/schedules/` — List/create notification schedules
- `GET/PUT/DELETE /api/notifications/schedules/<pk>/` — Schedule CRUD
- `GET/POST /api/notifications/patterns/` — List user patterns

**Push Notifications** (`shph-app/src/services/pushNotifications.ts` — 20KB):
- Firebase Cloud Messaging (FCM) integration
- Smart scheduling: respects quiet hours, max_per_day, frequency optimization
- Rich notification templates with action buttons
- Category-based notification routing (booking, message, payment, etc.)
- Background notification handling

### Frontend (Vue — `shph-app/src/`)

- `views/profile/NotificationsPage.vue` (16KB) — Full notification list with filters, mark read, delete
- `views/profile/NotificationPreferencesPage.vue` (30KB) — Full preferences UI with toggles, quiet hours, auto-dismiss
- `stores/notifications.ts` (4KB) — Pinia store: notifications list, unread count, WebSocket listener
- `services/pushNotifications.ts` (20KB) — FCM integration, smart scheduling
- `services/notifications/notificationScheduler.ts` — Smart scheduling logic
- `services/notifications/richNotifications.ts` — Rich notification templates
- `components/InAppNotification.vue` — In-app notification toast/banner

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_notifications_full_table.sql`:

```sql
-- Enhanced notifications table (replace existing if minimal)
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  from_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL DEFAULT 'system', -- booking, message, service, system, payment
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  verb TEXT DEFAULT '',
  redirect_url TEXT DEFAULT '',
  icon TEXT DEFAULT 'default',
  read BOOLEAN DEFAULT false,
  seen BOOLEAN DEFAULT false,
  data JSONB DEFAULT '{}',
  info JSONB DEFAULT '{}',
  fcm JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  timestamp TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notif_user ON notifications(user_id);
CREATE INDEX idx_notif_read ON notifications(read);
CREATE INDEX idx_notif_user_read ON notifications(user_id, read);
CREATE INDEX idx_notif_type ON notifications(type);

-- Notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  email_enabled BOOLEAN DEFAULT true,
  push_enabled BOOLEAN DEFAULT true,
  sms_enabled BOOLEAN DEFAULT false,
  booking_enabled BOOLEAN DEFAULT true,
  message_enabled BOOLEAN DEFAULT true,
  service_enabled BOOLEAN DEFAULT true,
  system_enabled BOOLEAN DEFAULT true,
  payments_enabled BOOLEAN DEFAULT true,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  quiet_allow_urgent BOOLEAN DEFAULT true,
  max_per_day SMALLINT DEFAULT 20,
  grouping BOOLEAN DEFAULT true,
  auto_dismiss TEXT DEFAULT '1d', -- never, 1h, 6h, 1d, 3d, 1w
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON notifications
  FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "System can insert notifications" ON notifications
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can manage own preferences" ON notification_preferences
  FOR ALL USING (auth.uid() = user_id);
```

### 2. Flutter Service

Create `lib/services/notifications_service.dart`:

Key methods:
- `getNotifications({unreadOnly, page, pageSize})` → Paginated list from Supabase
- `getUnreadCount()` → Count of unread notifications (replaces hardcoded `2` in `home_model.dart:34`)
- `markAsRead(notificationId)` → Update `read = true, seen = true`
- `markAllAsRead()` → Bulk update all user's notifications
- `deleteNotification(id)` → Delete single notification
- `getPreferences()` → Get user's notification preferences
- `updatePreferences(prefs)` → Update preferences
- `subscribeToRealtime()` → Supabase Realtime subscription for new notifications

**Realtime integration**:
```dart
supabase.channel('notifications')
  .onPostgresChange(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'notifications',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'user_id',
      value: userId,
    ),
    callback: (payload) {
      // Show in-app notification banner
      // Update unread count
      // Trigger FCM if push_enabled
    },
  )
  .subscribe();
```

### 3. Flutter UI

Pages to create:
- `lib/pages/notifications/notifications_list_widget.dart` — Notification list:
  - Filter tabs: All, Unread, Bookings, Messages, Payments
  - Swipe to delete
  - Tap to mark read + navigate (redirect_url)
  - "Mark all read" button
  - Empty state
- `lib/pages/notifications/notification_preferences_widget.dart` — Preferences:
  - Channel toggles (push, email, SMS)
  - Per-type toggles (booking, message, service, system, payments)
  - Quiet hours time pickers
  - Max per day slider
  - Auto-dismiss dropdown
- `lib/components/in_app_notification_banner.dart` — Toast/banner for new notifications

### 4. FCM Integration

- Already have Firebase configured in the mobile app (`firebase/` directory)
- Add `firebase_messaging` Flutter package
- Register FCM token on app launch
- Handle background notifications
- Handle notification taps (navigate to redirect_url)
- Respect notification preferences before showing push

### 5. Notification Triggers

Notifications should be created when:
- Booking status changes (pending→confirmed→en_route→in_progress→completed)
- New chat message received
- Payment confirmed
- Payment refunded
- Dispute status changed
- Provider verified/rejected
- Payout request status changed

Create a Supabase trigger function or use the existing Supabase Realtime to insert notification rows on table changes.

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/notifications/models.py` | All 4 notification models (332 lines) |
| `shph-api/src/shph/notifications/views.py` | All notification endpoints (559 lines) |
| `shph-app/src/views/profile/NotificationsPage.vue` | Notification list UI (16KB) |
| `shph-app/src/views/profile/NotificationPreferencesPage.vue` | Preferences UI (30KB) |
| `shph-app/src/stores/notifications.ts` | Pinia notification store (4KB) |
| `shph-app/src/services/pushNotifications.ts` | FCM integration (20KB) |
| `shph-app/src/services/notifications/notificationScheduler.ts` | Smart scheduling |
| `shph-app/src/services/notifications/richNotifications.ts` | Rich templates |
| `shph-app/src/components/InAppNotification.vue` | In-app banner component |

## Current Mobile App State

- `notifications` table exists in Supabase but is minimal
- `home_model.dart:34` has hardcoded `2` for notification count — needs to be replaced with real query
- No notification preferences exist
- No notification list page exists
- Firebase FCM is configured but not fully integrated for notifications
- `lib/services/` has no `notifications_service.dart`

## Key Differences for Flutter

- Web uses Django Channels WebSocket for realtime; mobile uses Supabase Realtime
- Web uses `send_push_notification` via RQ task queue; mobile uses `firebase_messaging` directly
- Web has smart scheduling logic in `notificationScheduler.ts`; mobile can simplify initially
- Web has `UserPattern` model for ML-based notification timing; mobile can skip initially
- Web notification model uses GenericForeignKey; mobile uses simpler `data` JSONB with type field
- Web auto-populates `info` cache with user details on save; mobile should do this in Dart or Supabase trigger
