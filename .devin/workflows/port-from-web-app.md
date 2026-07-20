---
description: Port a feature from the SHPH web app (Vue 3 + Django) to the Flutter mobile app
---

# Port Feature from Web App to Flutter

This workflow guides porting a feature from the **SHPH web version** (`C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version`) to this **Flutter mobile app** (`SerbisyoPH`).

## Context

- **Web app**: Vue 3 + Ionic + Capacitor frontend, Django + DRF backend
- **Mobile app**: Flutter frontend using the deployed SHPH API
- **Reference doc**: `docs/web_to_mobile_migration.md` in this repo

## Steps

### 1. Identify the Feature in the Web App

- Check `PROJECT_INDEX.md` in the web repo root for file locations
- Check `FLOWCHARTS.md` in the web repo root for feature flow diagrams
- Identify:
  - Frontend page(s): `shph-app/src/views/<section>/<Name>Page.vue`
  - Frontend store(s): `shph-app/src/stores/<domain>.ts`
  - Frontend service(s): `shph-app/src/services/<name>.ts`
  - Backend endpoint(s): `shph-api/src/shph/<app>/views.py`
  - Backend model(s): `shph-api/src/shph/<app>/models.py`
  - API spec: `SHPH API.yaml` in this repo's root

### 2. Map the Data Model

- Compare the Django model to the Flutter API model
- Check `docs/api_gaps.md` for known missing fields and entities
- Note any fields that are not represented by the Flutter model

### 3. Check API Coverage

- Check if the Flutter API client (`lib/api/resources/`) has the method
- Verify the endpoint against `SHPH API.yaml` and the production web client
- Add or extend the corresponding SHPH API resource; do not add direct
  Supabase or provider-specific network calls

### 4. Implement the Flutter UI

- Create the page widget in `lib/pages/<feature_name>/`
- Add `static const String routeName` and `static const String routePath`
- Register the route in `lib/router/app_router.dart`
- Export the widget in `lib/index.dart`
- Follow the theme in `lib/theme/app_theme.dart`
- Follow patterns from `AI_DEVELOPMENT_PROMPT.md`

### 5. Implement the Business Logic

- Create or extend a service in `lib/services/`
- Use Supabase queries following existing patterns:
  - `.select()` with field selection
  - `.eq()` for equality filters
  - `.order()` for sorting
  - `.maybeSingle()` for optional single results
  - Handle null responses gracefully
  - Check column types (UUID vs INTEGER)
- Add error logging via `LoggingService`

### 6. Handle State Management

- Use `StatefulWidget` with `setState` for local state (current pattern)
- Use `FFAppState` (`lib/app_state.dart`) for global state
- Add `isLoading` boolean for loading states
- Always check `mounted` before calling `setState`

### 7. Test Both User Flows

- Test as client user
- Test as provider user
- Verify navigation works (route is registered)
- Verify Supabase queries execute without errors
- Verify RLS policies are in place
- Verify loading and error states display correctly

### 8. Update Documentation

- Update `docs/web_to_mobile_migration.md` — mark the feature as ported
- Update `docs/api_gaps.md` if API coverage changed
- Update `AI_DEVELOPMENT_PROMPT.md` if new patterns were introduced

## Key Differences to Watch For

| Concern | Web App | Mobile App |
|---------|---------|------------|
| Booking ID | String (ObjectId) | UUID |
| Role model | `is_provider` / `is_client` booleans | `role` string field |
| Chat backend | MongoDB via Djongo | Supabase Postgres |
| Realtime | Django Channels + WebSocket | Supabase Realtime |
| State management | Pinia stores | StatefulWidget + FFAppState |
| HTTP client | Axios | Dio |
| Maps | Leaflet | Google Maps |
| Payments | PayMongo | Not implemented |
| Video calls | WebRTC (native) | Not implemented |
