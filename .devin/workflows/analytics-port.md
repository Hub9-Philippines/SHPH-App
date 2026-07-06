---
description: Port the provider analytics dashboard from the web app to Flutter mobile
---

# Skill: Port Provider Analytics Dashboard

Port the comprehensive analytics dashboard for service providers from the web app to the Flutter mobile app.

---

## What the Web App Has

### Backend (Django — `shph-api/src/shph/analytics/`)

**Views** (`analytics/views.py` — 834 lines):
- `POST /api/analytics/provider/` — Comprehensive provider analytics:
  - Period filter (today, week, month, year, all)
  - **Booking metrics**: total, completed, pending, cancelled, completion rate
  - **Revenue metrics**: total revenue, average booking value, revenue trend
  - **Review metrics**: average rating, total reviews, rating distribution
  - **Recommendation metrics**: profile views, conversion rate
  - **Client metrics**: total clients, repeat clients, avg days to rebook
  - **Time metrics**: avg response time, avg completion time
  - **Monthly trend**: 6-month revenue & booking chart data
  - **Top services**: best-performing listings by bookings & revenue
  - **Earnings breakdown**: credits, payouts, pending, available

### Frontend (Vue — `shph-app/src/`)

- `views/provider/ProviderAnalyticsPage.vue` (22KB) — Full analytics dashboard:
  - Period selector (today/week/month/year/all)
  - Summary stat cards (bookings, revenue, rating, clients)
  - Revenue trend chart (Chart.js line chart, 6 months)
  - Booking status breakdown (Chart.js doughnut)
  - Rating distribution (Chart.js bar chart)
  - Top services table
  - Client metrics
  - Response time metrics

- `components/analytics/BookingMetrics.vue` — Booking stat cards
- `components/analytics/EarningsChart.vue` — Earnings line chart

---

## What the Mobile App Needs

### 1. Flutter Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.66.0  # Or syncfusion_flutter_charts: ^25.0.0
```

### 2. Flutter Service

Create `lib/services/analytics_service.dart`:

Key methods:
- `getProviderAnalytics({period})` → Aggregate analytics from Supabase:
  - Query bookings for metrics (total, completed, pending, cancelled)
  - Query earnings_transactions for revenue
  - Query reviews for rating metrics
  - Query service_listings for top services
  - Calculate monthly trends (last 6 months)

**Analytics calculation** (direct Supabase queries):
```dart
Future<ProviderAnalytics> getProviderAnalytics({String period = 'month'}) async {
  final now = DateTime.now();
  final startDate = _getPeriodStart(period, now);
  
  // Booking metrics
  final bookings = await supabase.from('bookings')
    .select('status, total_amount, created_at')
    .eq('pro_id', userId)
    .gte('created_at', startDate.toIso8601String());
  
  final total = bookings.length;
  final completed = bookings.where((b) => b['status'] == 'completed').length;
  final pending = bookings.where((b) => b['status'] == 'pending').length;
  final cancelled = bookings.where((b) => b['status'] == 'cancelled').length;
  final completionRate = total > 0 ? completed / total : 0;
  
  // Revenue
  final revenue = bookings
    .where((b) => b['status'] == 'completed')
    .fold(0.0, (sum, b) => sum + (b['total_amount'] ?? 0));
  
  // Reviews
  final reviews = await supabase.from('reviews')
    .select('rating')
    .eq('pro_id', userId);
  
  final avgRating = reviews.isNotEmpty
    ? reviews.map((r) => r['rating'] as num).reduce((a, b) => a + b) / reviews.length
    : 0;
  
  // Monthly trend (last 6 months)
  final monthlyData = await _getMonthlyTrend(userId, 6);
  
  return ProviderAnalytics(
    totalBookings: total,
    completedBookings: completed,
    pendingBookings: pending,
    cancelledBookings: cancelled,
    completionRate: completionRate,
    totalRevenue: revenue,
    avgRating: avgRating,
    totalReviews: reviews.length,
    monthlyTrend: monthlyData,
  );
}
```

### 3. Flutter UI

Create `lib/pages/analytics/analytics_widget.dart`:
- Period selector (segmented control: Today, Week, Month, Year, All)
- Summary cards grid (2×2): Total Bookings, Revenue, Avg Rating, Completion Rate
- Revenue trend line chart (`fl_chart` LineChart)
- Booking status doughnut chart (`fl_chart` PieChart)
- Rating distribution bar chart (`fl_chart` BarChart)
- Top services list (title, booking count, revenue)
- Client metrics section (total clients, repeat rate)
- Pull-to-refresh

### 4. Data Models

Create `lib/models/provider_analytics.dart`:
- `ProviderAnalytics` — totalBookings, completedBookings, pendingBookings, cancelledBookings, completionRate, totalRevenue, avgBookingValue, avgRating, totalReviews, ratingDistribution, monthlyTrend, topServices, totalClients, repeatClients, avgResponseTime, avgCompletionTime

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-api/src/shph/analytics/views.py` | Full analytics endpoint (834 lines) |
| `shph-app/src/views/provider/ProviderAnalyticsPage.vue` | Analytics dashboard UI (22KB) |
| `shph-app/src/components/analytics/BookingMetrics.vue` | Booking stat cards |
| `shph-app/src/components/analytics/EarningsChart.vue` | Earnings chart component |

## Current Mobile App State

- Pro dashboard exists (`lib/main/pro_dashboard/`) but has no analytics
- No analytics service exists in `lib/services/`
- No chart library in pubspec.yaml

## Key Differences for Flutter

- Web uses Chart.js for visualizations; mobile should use `fl_chart` or `syncfusion_flutter_charts`
- Web computes analytics server-side with Django ORM aggregates; mobile should compute client-side from Supabase queries (or create Supabase RPC for complex aggregations)
- Web has `_avg_days_to_rebook` helper; mobile can implement same in Dart
- Web has period filter in API; mobile should filter by date range in Supabase queries
- Web returns monthly trend as array; mobile should format for `fl_chart` data model
