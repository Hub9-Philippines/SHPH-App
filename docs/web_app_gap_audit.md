# Web App Gap Audit — SHPH_web_version

> **Audited:** 2026-07-06
> **Repo (local):** `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version`
> **Repo (GitLab):**
> - Root (submodule parent): https://gitlab.com/shph1/shph.git
> - Backend (`shph-api`): https://gitlab.com/shph1/shph-api.git
> - Frontend (`shph-app`): https://gitlab.com/shph1/shph-app.git

This audit consolidates findings from the web app's own prior self-audits (`BIDDING_AUDIT_REPORT.md`, `orm-audit-findings.md`) plus a fresh scan, cross-checked against `CHANGELOG.md` to exclude already-resolved items. **Note:** these source audits are dated May 2026 — verify against `CHANGELOG.md` before implementing, in case items were already fixed since.

---

## Summary Table

| # | Area | Status | Severity | Source | Repo |
|---|------|--------|----------|--------|------|
| 1 | Rate limiting missing on `OnDemandJobAcceptView` | ❌ Missing | P0 | BIDDING_AUDIT_REPORT.md | shph-api |
| 2 | N+1 queries in `OnDemandBidSerializer.get_provider` | ⚠️ Inefficient | P0/P1 | BIDDING_AUDIT_REPORT.md + orm-audit-findings.md | shph-api |
| 3 | Push notifications for on-demand events | ⚠️ Partial (50%) | P0 | BIDDING_AUDIT_REPORT.md | shph-api |
| 4 | Provider availability check before bidding | ❌ Missing | P0 | BIDDING_AUDIT_REPORT.md | shph-api |
| 5 | Bid price ceiling validation | ❌ Missing | P0 | BIDDING_AUDIT_REPORT.md | shph-api |
| 6 | `OnDemandBidViewSet` not registered in Wagtail admin | ❌ Missing | P0 | BIDDING_AUDIT_REPORT.md | shph-api |
| 7 | N+1 in on-demand fee estimation (Python-loop haversine) | ⚠️ Inefficient | CRITICAL | orm-audit-findings.md | shph-api |
| 8 | N+1 in `BookingSerializer` via `_booking_queryset_for_user` | ⚠️ Inefficient | HIGH | orm-audit-findings.md | shph-api |
| 9 | Provider "My Bids" page missing | ❌ Missing | P1 | BIDDING_AUDIT_REPORT.md | shph-app |
| 10 | Client "My On-Demand Jobs" history page missing | ❌ Missing | P1 | BIDDING_AUDIT_REPORT.md | shph-app |
| 11 | Provider bid withdrawal endpoint + UI missing | ❌ Missing | P1 | BIDDING_AUDIT_REPORT.md | both |
| 12 | Auto-expire PENDING bids on job expiry | ❌ Missing | P1 | BIDDING_AUDIT_REPORT.md | shph-api |
| 13 | Admin/Ops tooling for bidding (analytics, retention cron, audit log) | ❌ Mostly missing (30%) | P2 | BIDDING_AUDIT_REPORT.md | shph-api |
| 14 | `NotificationListView` missing `prefetch_related` on generic FK | ⚠️ Inefficient | LOW | orm-audit-findings.md | shph-api |
| 15 | `TrackInteractionView` race condition (read-then-write duplicate check) | ⚠️ Bug risk | LOW | orm-audit-findings.md | shph-api |

---

## Detailed Findings (Top Priority)

### 1. Missing Rate Limiting — `OnDemandJobAcceptView`
- **File:** `shph-api/src/shph/services/views.py` (GitLab: `shph-api/-/blob/main/src/shph/services/views.py`)
- **Issue:** No `ScopedRateThrottle` on the provider-bid endpoint — vulnerable to spam/abuse.
- **Fix:**
  ```python
  class OnDemandJobAcceptView(APIView):
      permission_classes = [permissions.IsAuthenticated]
      throttle_classes = [ScopedRateThrottle]
      throttle_scope = "on_demand_bid"
  ```
  Add to Django settings: `"DEFAULT_THROTTLE_RATES": {"on_demand_bid": "10/minute"}`
- **Effort:** 30 min

### 2/7. N+1 Queries — On-Demand Fee Estimation & Bid Serializer
- **Files:**
  - `shph-api/src/shph/services/views.py:168-232` (`_estimate_on_demand_fee`, `_nearby_provider_ids`)
  - `shph-api/src/shph/services/serializers.py:435-454` (`OnDemandBidSerializer.get_provider`)
- **Issue:** Python-loop haversine distance calculation (O(N) per request) instead of SQL `RawSQL` annotation; bid serializer runs 2 extra aggregate queries **per bid**.
- **Fix:** Push haversine into SQL via `RawSQL` annotation (pattern already used correctly in `ServiceListingListCreateView.get_queryset`); pre-compute provider stats in the view and pass via serializer context.
- **Effort:** 2-3 hrs combined

### 3. Push Notifications for On-Demand Events (50% partial)
- **Files:** `shph-api/src/shph/notifications/` + `shph-api/src/shph/services/views.py`
- **Issue:** Providers miss on-demand job offers when app is closed — no FCM push triggered on job broadcast.
- **Effort:** 1 day

### 4. Provider Availability Check Before Bidding
- **File:** `shph-api/src/shph/services/views.py` (`OnDemandJobAcceptView`)
- **Fix:**
  ```python
  if not ProviderAvailability.objects.filter(
      provider=provider, day_of_week=now.weekday(), is_active=True,
      start_time__lte=now.time(), end_time__gte=now.time(),
  ).exists():
      return Response({"detail": "You are not currently available."}, status=400)
  ```
- **Effort:** 2 hrs

### 5. Bid Price Ceiling Validation
- **File:** `shph-api/src/shph/services/views.py`
- **Issue:** No server-side cap on provider bid price — a malicious/buggy provider could submit an absurd price.
- **Effort:** 1 hr

### 6. `OnDemandBidViewSet` Not in Wagtail Admin
- **File:** `shph-api/src/shph/services/wagtail_hooks.py`
- **Effort:** 30 min

### 8. `BookingSerializer` N+1 via `_booking_queryset_for_user`
- **File:** `shph-api/src/shph/services/views.py:217-221`
- **Fix:**
  ```python
  def _booking_queryset_for_user(user):
      qs = (ServiceBooking.objects.filter(client=user)
            | ServiceBooking.objects.filter(listing__provider=user))
      return qs.select_related("listing__provider", "client").prefetch_related(
          "payment", "review", "on_demand_job"
      )
  ```
- **Impact:** ~60-80 queries → ~1 query for a 20-booking list.
- **Effort:** 30 min

### 9/10. Missing "My Bids" / "My On-Demand Jobs" History Pages
- **Files (new):** `shph-app/src/views/provider/` (ProviderBidsPage.vue already exists per file listing — verify it's wired up), client-side history page missing entirely
- **Effort:** 1 day each

---

## Suggested Fix Order (Highest ROI First)

1. **Fix #8** — `BookingSerializer` N+1 (30 min, HIGH impact, every booking list request)
2. **Fix #1** — Rate limiting on bid endpoint (30 min, security-critical)
3. **Fix #6** — Register `OnDemandBidViewSet` in Wagtail (30 min, admin visibility)
4. **Fix #5** — Bid price ceiling validation (1 hr, prevents abuse)
5. **Fix #4** — Provider availability check (2 hrs, UX correctness)
6. **Fix #2/7** — N+1 in fee estimation + bid serializer (2-3 hrs, scales with traffic)
7. **Fix #3** — Push notifications for on-demand (1 day, high UX value)
8. **Fix #9/10** — Bid/job history pages (1 day each, UX completeness)

Items #1, #6, #8 are one-line-to-small changes with immediate, low-risk impact — good candidates for a fast first pass.

---

## Resolution Log

> **Verification run: 2026-07-06.** The source audits (`BIDDING_AUDIT_REPORT.md`, `orm-audit-findings.md`) are dated May 2026. Before implementing, the actual current code was re-checked — **all 8 P0 items were found already fixed**, confirmed by `CHANGELOG.md` entries and direct code inspection. No code changes were made to avoid touching already-correct code.

| # | Status | Date | Notes |
|---|--------|------|-------|
| 1 | ✅ Already Resolved | verified 2026-07-06 | `OnDemandJobAcceptView` has `throttle_classes = [ScopedRateThrottle]`, `throttle_scope = "on_demand_bid"` — `services/views.py:2496-2497` |
| 2/7 | ✅ Already Resolved | verified 2026-07-06 | Haversine now computed via `RawSQL` annotation in `_nearby_provider_ids`/`_estimate_on_demand_fee` (`services/views.py:213-303`); bid provider stats pre-annotated via `_annotate_bid_provider_stats()` (`services/views.py:318-338`) and read from annotations in `OnDemandBidSerializer.get_provider` (`services/serializers.py:559-577`) — no more per-bid aggregate queries |
| 3 | ✅ Already Resolved | verified 2026-07-06 | FCM push sent to every nearby provider on broadcast via `try_enqueue(send_push_notification, ...)` — `services/views.py:2298-2315` |
| 4 | ✅ Already Resolved | verified 2026-07-06 | Provider availability check present in `OnDemandJobAcceptView` — `services/views.py:2529-2543` |
| 5 | ✅ Already Resolved | verified 2026-07-06 | Bid price ceiling check (`_MAX_ON_DEMAND_PRICE`) present — `services/views.py:2558-2565` |
| 6 | ✅ Already Resolved | verified 2026-07-06 | `OnDemandBidViewSet` registered in `ServicesViewSetGroup` — `services/wagtail_hooks.py:160-161,234` |
| 8 | ✅ Already Resolved | verified 2026-07-06 | `_booking_queryset_for_user` has `select_related("listing__provider","client")` + `prefetch_related("payment","review","on_demand_job")` — `services/views.py:306-315` |
| 9/10 | ✅ Already Resolved | verified 2026-07-06 | Both `ProviderBidsPage.vue` and `ClientOnDemandJobsPage.vue` exist in `shph-app/src/views/` |
| 11 | ✅ Already Resolved | verified 2026-07-06 | `OnDemandBidWithdrawView` implemented — `services/views.py:2792-2839` |
| 12 | ✅ Already Resolved | verified 2026-07-06 | Auto-expire logic present in job status poll + `_expire_pending_bids()` — `services/views.py:2521-2527, 2718-2731` |
| 14 | ⚠️ Still Open (LOW) | unverified fix | `notifications/views.py` `NotificationListView` still has no `prefetch_related` for generic FK `content_object` — low impact, not yet addressed |
| 15 | ⚠️ Partially Mitigated (LOW) | verified 2026-07-06 | `TrackInteractionView` now wraps the dedup check in `transaction.atomic()` (`analytics/views.py:804`), which reduces but does not fully eliminate the read-then-write race under Postgres READ COMMITTED isolation (no row lock exists to take since the row doesn't exist yet). The audit's suggested `get_or_create()` with a DB-level unique constraint was not applied. |
| 13 | ❓ Not Re-verified | — | Broader Admin/Ops tooling (analytics, retention cron, SMS fallback, audit log, Sentry) — P2, out of scope for this run |

### Outcome for this run

**No code changes were made.** All 8 items the user approved ("All P0 items #1-8") are already implemented in the current codebase — implementing them again would have been redundant/no-op work. Two minor LOW-severity items (#14, #15) remain genuinely open if you want them addressed in a follow-up run.
