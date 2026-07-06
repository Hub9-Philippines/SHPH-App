---
description: Port the AI recommendation engine from the web app to Flutter mobile
---

# Skill: Port AI Recommendations System

Port the AI-powered service recommendation engine from the web app to the Flutter mobile app.

---

## What the Web App Has

### Frontend (Vue — `shph-app/src/`)

**Recommendation Engine** (`services/recommendations.ts` — 23KB, 748 lines):
- `RecommendationEngine` class (singleton)
- Uses TensorFlow.js for ML model
- Collaborative filtering with user/service embeddings
- Loads pre-trained model or creates new one
- Caches embeddings in localStorage
- Backend failure threshold: disables after 3 consecutive 403/404/405 errors
- Falls back to content-based recommendations when backend unavailable

**Recommendation Store** (`stores/recommendations.ts` — 9.5KB):
- Pinia store: recommendations list, loading state, error state
- Fetches recommendations from backend API
- Falls back to local engine when backend unavailable

**Models** (`models/RecommendationModel.ts`):
- `UserInteraction` — userId, serviceId, interactionType (view/booking/favorite/review/rating)
- `ServiceRecommendation` — service data + recommendation reason + score
- `RecommendationContext` — user context (location, history, preferences)
- `RecommendationReason` — why this service was recommended
- `RecommendationSet` — batch of recommendations with metadata

**UI Components**:
- `components/recommendations/RecommendationCard.vue` — Single recommendation card
- `components/recommendations/ServiceRecommendations.vue` — Recommendation carousel/section
- Shown on home page and service detail page

### Backend (Django — `shph-api/src/shph/recommendations/`)

**Models** (`recommendations/models.py`):
- `UserInteraction` — user, service, interaction_type (view/booking/favorite/review/rating), weight, created_at
- `UserPreference` — user, category preferences (JSON), price_range, location_preference

**Views** (`recommendations/views.py` — 976 lines):
- `POST /api/recommendations/` — Get personalized recommendations
  - Uses collaborative filtering + content-based filtering
  - Factors: user interactions, category preferences, location (haversine distance), popularity, ratings
  - Returns scored & ranked service listings with recommendation reasons
- `POST /api/recommendations/track/` — Track user interaction (view, booking, favorite, review)
- `GET /api/recommendations/popular/` — Popular services (by booking count, rating, recency)
- `GET /api/recommendations/similar/<service_id>/` — Similar services (same category, similar price)
- `POST /api/recommendations/preferences/` — Get/update user preferences

**Algorithm** (server-side, `_batch_popularity_stats` + scoring):
1. **Collaborative filtering**: Users with similar interactions → recommend their services
2. **Content-based**: Same category, similar price range, similar location
3. **Popularity**: Recent bookings, completed bookings, avg rating, favorite count, unique clients
4. **Location**: Haversine distance from user's default address
5. **Recency boost**: Recent interactions weighted higher
6. **Final score**: Weighted combination of all factors

---

## What the Mobile App Needs

### 1. Supabase Tables (SQL Migration)

Create `database/create_recommendations_tables.sql`:

```sql
-- User interactions table
CREATE TABLE IF NOT EXISTS user_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  service_id INTEGER REFERENCES service_listings(id) ON DELETE CASCADE,
  interaction_type TEXT NOT NULL, -- view, booking, favorite, review, rating
  weight FLOAT DEFAULT 1.0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_interactions_user ON user_interactions(user_id);
CREATE INDEX idx_interactions_service ON user_interactions(service_id);
CREATE INDEX idx_interactions_type ON user_interactions(interaction_type);
CREATE INDEX idx_interactions_user_type ON user_interactions(user_id, interaction_type);

-- User preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  category_preferences JSONB DEFAULT '{}',
  price_range_min DECIMAL(10,2),
  price_range_max DECIMAL(10,2),
  location_preference TEXT, -- city/province
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own interactions" ON user_interactions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own interactions" ON user_interactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can manage own preferences" ON user_preferences
  FOR ALL USING (auth.uid() = user_id);
```

### 2. Flutter Service

Create `lib/services/recommendations_service.dart`:

Key methods:
- `getRecommendations({limit, offset})` → Get personalized recommendations
  - Query user_interactions to find preferred categories
  - Query service_listings in preferred categories
  - Score by: category match, price range, rating, proximity, popularity
  - Return sorted list with recommendation reasons
- `trackInteraction(serviceId, type)` → Insert user_interaction record
- `getPopularServices({limit})` → Popular services by booking count + rating
- `getSimilarServices(serviceId, {limit})` → Same category, similar price
- `getPreferences()` → Get user preferences
- `updatePreferences(prefs)` → Update preferences

**Simplified scoring algorithm** (no TensorFlow needed):
```dart
double _scoreService(listing, userPrefs, userLocation) {
  double score = 0;
  // Category match (40%)
  if (userPrefs.preferredCategories.contains(listing.category)) {
    score += 40;
  }
  // Price range match (20%)
  if (listing.baseRate >= userPrefs.minPrice && listing.baseRate <= userPrefs.maxPrice) {
    score += 20;
  }
  // Rating (20%)
  score += (listing.ratingAvg ?? 0) * 4; // 0-5 → 0-20
  // Proximity (20%)
  if (userLocation != null && listing.latitude != null) {
    final distance = _haversine(userLocation, listing.latLng);
    score += max(0, 20 - distance); // closer = higher score
  }
  return score;
}
```

### 3. Flutter UI

Components to create:
- `lib/components/recommendations/recommendation_card_widget.dart` — Service card with "Recommended for you" label + reason
- `lib/components/recommendations/recommendation_section_widget.dart` — Horizontal scrollable section on home page
- `lib/components/recommendations/similar_services_widget.dart` — "Similar services" section on service detail page

### 4. Integration Points

- Add recommendation section to home page (`lib/main/home/`)
- Add "Similar services" to service detail page (`lib/pages/service_details/`)
- Track interactions: view (on service detail), booking (on checkout), favorite (on favorite toggle), review (on review submit)
- Track on app launch: initialize preferences from user's booking history

### 5. Interaction Tracking

Call `trackInteraction` at these points:
- User views a service detail page → `interaction_type: 'view'`
- User completes a booking → `interaction_type: 'booking', weight: 3.0`
- User favorites a service → `interaction_type: 'favorite', weight: 2.0`
- User leaves a review → `interaction_type: 'review', weight: 2.5`
- User rates a service → `interaction_type: 'rating', weight: 2.0`

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-app/src/services/recommendations.ts` | Full ML recommendation engine (748 lines) |
| `shph-app/src/stores/recommendations.ts` | Pinia recommendation store (9.5KB) |
| `shph-app/src/models/RecommendationModel.ts` | TypeScript interfaces |
| `shph-app/src/components/recommendations/RecommendationCard.vue` | Recommendation card UI |
| `shph-app/src/components/recommendations/ServiceRecommendations.vue` | Recommendation section UI |
| `shph-api/src/shph/recommendations/views.py` | Backend recommendation endpoints (976 lines) |
| `shph-api/src/shph/recommendations/models.py` | UserInteraction & UserPreference models |

## Key Differences for Flutter

- Web uses TensorFlow.js for ML; mobile should use simplified scoring algorithm (no ML library needed initially)
- Web has collaborative filtering via embeddings; mobile can start with content-based + popularity scoring
- Web caches embeddings in localStorage; mobile can cache recommendations in SharedPreferences
- Web has backend fallback to local engine; mobile should query Supabase directly
- Web uses haversine distance with PostGIS; mobile should use same formula in Dart
- Web tracks interactions via API; mobile should insert directly to Supabase
- Can add TensorFlow Lite later for true ML-based recommendations if needed
