# Cross-Repo Context Rules

## Two Repositories

This project spans two repositories that share the same product (SerbisyoHub PH):

### 1. Web App (Original — First Development)
- **Path**: `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version`
- **Stack**: Vue 3 + Ionic 8 + Capacitor 8 (frontend), Django 6 + DRF + Wagtail (backend)
- **Database**: PostgreSQL + MongoDB via Djongo
- **Status**: Original implementation with full feature set (~200 API endpoints)

### 2. Mobile App (Current — Porting from Web)
- **Path**: `C:\Users\Pol\Desktop\DEV\StartUp\SerbisyoPH` (this repo)
- **Stack**: Flutter 3.x (frontend), Node.js Express + Supabase (backend)
- **Database**: PostgreSQL via Supabase
- **Status**: Active development, porting features from web app

## Rules When Working Across Repos

1. **Always check the web app first** when implementing a feature that exists there. The web app is the source of truth for business logic and feature behavior.

2. **Use `docs/web_to_mobile_migration.md`** as the primary reference for feature mapping and porting status.

3. **The web app's `PROJECT_INDEX.md`** maps every feature to file locations in both `shph-api/` and `shph-app/`.

4. **The web app's `FLOWCHARTS.md`** has Mermaid diagrams for every major user flow — use these to understand expected behavior before implementing in Flutter.

5. **The web app's `AGENTS.md` and `.cursorrules`** contain critical constraints (Djongo-safe rules, POST-over-GET pattern, booking ID as string, role booleans).

6. **`SHPH API.yaml`** in this repo's root is the OpenAPI spec that describes all endpoints — use it to check what the API should look like.

7. **`docs/api_gaps.md`** in this repo documents what's missing in the mobile app's API layer vs the spec.

8. **When porting a feature**, use the `/port-from-web-app` workflow.

## Key Architectural Differences to Remember

| Concern | Web App | Mobile App |
|---------|---------|------------|
| Booking ID | String (ObjectId, 24 chars) | UUID |
| Role model | `is_provider` / `is_client` booleans | `role` string field |
| Chat storage | MongoDB (Djongo) | Supabase Postgres |
| Realtime | Django Channels + WebSocket | Supabase Realtime |
| API completeness | ~200 endpoints | ~22 endpoints |
| Primary data access | Django ORM via API | Direct Supabase queries (62+ bypass API) |
| Payments | PayMongo (full integration) | Not implemented |
| Video calls | WebRTC (full integration) | Not implemented |
| Recommendations | ML engine (collaborative filtering) | Not implemented |
| Admin panel | Wagtail CMS + Django admin | Not implemented |
