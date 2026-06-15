# Project: SerbisyoHub PH - Native Android (Kotlin) Rebuild

## Overview
Rebuild the SerbisyoHub PH service marketplace application as a native Android app using Kotlin. The app connects Filipino service providers with customers, featuring phone authentication, EKYC verification, service bookings, real-time chat, and a pro dashboard.

## Tech Stack

### Frontend (Android Native)
- **Language**: Kotlin
- **UI Framework**: Jetpack Compose (Material 3)
- **Architecture**: MVVM with Clean Architecture
- **Dependency Injection**: Hilt
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil
- **Async**: Coroutines + Flow
- **Local Storage**: Room Database
- **Navigation**: Jetpack Navigation Compose
- **State Management**: StateFlow + ViewModel
- **Image Picker**:ActivityResultContracts
- **Camera**: CameraX

### Backend
- **BaaS**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Alternative**: Firebase (Firestore, Auth, Storage) if preferred
- **API**: RESTful API via Supabase client or direct PostgreSQL

### Additional Services
- **PSGC API**: Philippine Standard Geographic Code for location selection
- **Payment**: GCash, Maya integration (via payment gateway)

## Database Schema (Supabase/PostgreSQL)

### Tables

1. **profiles**
```sql
- id: UUID (PK, auth.uid())
- email: TEXT
- phone: TEXT (unique)
- first_name: TEXT
- last_name: TEXT
- display_name: TEXT
- photo_url: TEXT
- bio: TEXT
- role: TEXT (enum: 'client', 'pro')
- verification_status: TEXT (enum: 'unverified', 'pending', 'verified', 'rejected')
- is_verified: BOOLEAN
- is_face_verified: BOOLEAN
- is_profile_complete: BOOLEAN
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

2. **service_listings**
```sql
- id: INTEGER (PK, auto-increment)
- pro_id: UUID (FK -> profiles.id)
- title: TEXT
- description: TEXT
- category: TEXT
- base_rate: NUMERIC
- rate_unit: TEXT (hourly, fixed, per_session)
- location: TEXT
- photos: TEXT[] (array of URLs)
- availability: JSON (schedule data)
- rating_avg: NUMERIC
- rating_count: INTEGER
- is_active: BOOLEAN
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

3. **bookings**
```sql
- id: UUID (PK)
- client_id: UUID (FK -> profiles.id)
- service_id: INTEGER (FK -> service_listings.id)
- pro_id: UUID (FK -> profiles.id)
- status: TEXT (enum: 'pending', 'accepted', 'in_progress', 'completed', 'cancelled')
- scheduled_date: TIMESTAMP
- scheduled_time: TEXT
- duration: INTEGER (minutes)
- location: TEXT
- notes: TEXT
- total_amount: NUMERIC
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

4. **chat_rooms**
```sql
- id: UUID (PK)
- client_id: UUID (FK -> profiles.id)
- provider_id: INTEGER (FK -> service_listings.id)
- provider_name: TEXT
- provider_photo: TEXT
- last_message: TEXT
- last_message_time: TIMESTAMP
- unread_count: INTEGER
- unread_provider_count: INTEGER
- last_message_id: UUID (FK -> chat_messages.id)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

5. **chat_messages**
```sql
- id: UUID (PK)
- chat_room_id: UUID (FK -> chat_rooms.id)
- sender_id: UUID (FK -> profiles.id)
- content: TEXT
- message_type: TEXT (text, image)
- created_at: TIMESTAMP
```

6. **notifications**
```sql
- id: UUID (PK)
- user_id: UUID (FK -> profiles.id)
- type: TEXT (booking, message, review, system)
- title: TEXT
- body: TEXT
- data: JSON
- is_read: BOOLEAN
- created_at: TIMESTAMP
```

7. **payment_methods**
```sql
- id: UUID (PK)
- user_id: UUID (FK -> profiles.id)
- type: TEXT (gcash, maya, card)
- provider: TEXT
- account_number: TEXT (encrypted)
- is_default: BOOLEAN
- created_at: TIMESTAMP
```

8. **reviews**
```sql
- id: UUID (PK)
- booking_id: UUID (FK -> bookings.id)
- service_id: INTEGER (FK -> service_listings.id)
- pro_id: UUID (FK -> profiles.id)
- client_id: UUID (FK -> profiles.id)
- rating: INTEGER (1-5)
- comment: TEXT
- created_at: TIMESTAMP
```

## Android Project Structure

```
app/
├── data/
│   ├── local/
│   │   ├── dao/
│   │   ├── entity/
│   │   └── database/
│   ├── remote/
│   │   ├── api/
│   │   ├── dto/
│   │   └── supabase/
│   └── repository/
├── domain/
│   ├── model/
│   ├── repository/
│   └── usecase/
├── presentation/
│   ├── auth/
│   │   ├── phone/
│   │   ├── verify/
│   │   └── post_auth/
│   ├── verification/
│   │   ├── document/
│   │   └── face/
│   ├── main/
│   │   ├── home/
│   │   ├── search/
│   │   ├── bookings/
│   │   ├── chat/
│   │   └── profile/
│   ├── pro_dashboard/
│   │   ├── jobs/
│   │   ├── schedule/
│   │   ├── earnings/
│   │   ├── messages/
│   │   └── profile/
│   │       ├── edit/
│   │       ├── service_history/
│   │       ├── reviews/
│   │       ├── help/
│   │       ├── about/
│   │       └── create_service/
│   └── common/
│       ├── components/
│       └── theme/
└── di/
```

## Key Features Implementation

### 1. Authentication Flow
- **Phone Auth**: Use Supabase Auth with OTP via SMS
- **Post-Auth Navigation**: Check user role and verification status
  - New users → Profile completion
  - Pro users → EKYC verification flow
  - Verified pros → Pro Dashboard
  - Clients → Main app

### 2. EKYC Verification
- **Document Scan**: Use CameraX for ID capture, ML Kit for text extraction
- **Face Verification**: Compare live face with ID photo using ML Kit Face Detection
- **4-State Lifecycle**: Unverified → Pending → Verified/Rejected

### 3. Service Listings
- **Create Service**: Form with image upload (Supabase Storage), category dropdown
- **Search/Filter**: By category, location, rating, price range
- **PSGC Integration**: Fetch regions/provinces/cities from PSGC API

### 4. Booking System
- **Book Service**: Select date/time, confirm booking
- **Pro Dashboard**: View pending requests, accept/reject
- **Schedule**: View upcoming jobs, mark as complete
- **Status Updates**: Real-time via Supabase Realtime

### 5. Chat System
- **Real-time Messaging**: Supabase Realtime subscriptions
- **Chat Rooms**: Separate rooms for each booking
- **Unread Counts**: Track per user (client vs provider)
- **Push Notifications**: Firebase Cloud Messaging

### 6. Pro Dashboard
- **Jobs Tab**: Pending requests with accept/reject
- **Schedule Tab**: Upcoming jobs with completion status
- **Earnings Tab**: Calculate from completed bookings, show summary
- **Messages Tab**: Chat rooms with customers
- **Profile Tab**: Edit profile, service history, reviews, help, about

### 7. Reviews & Ratings
- **Submit Review**: After booking completion
- **Display Reviews**: On service listing and pro profile
- **Rating Distribution**: Star breakdown

## API Integration

### Supabase Client Setup
```kotlin
// Use supabase-kt library or direct REST API
// Implement repository pattern for data access
```

### PSGC API
```kotlin
// Fetch geographic data for location selection
// Endpoint: https://psgc.gitlab.io/api/
```

## UI Components (Jetpack Compose)

### Common Components
- `Scaffold` with bottom navigation
- `LazyColumn` for lists
- `Card` for service listings/chat rooms
- `CircularProgressIndicator` for loading
- `PullRefresh` for refresh
- `AlertDialog` for confirmations

### Custom Components
- `ServiceCard`: Display service with photo, title, rating, price
- `ChatRoomCard`: Display conversation with user photo, last message
- `BookingCard`: Display booking with status, date, action buttons
- `ReviewCard`: Display review with user photo, rating, comment
- `RatingBar`: Star rating display/input

## State Management

### ViewModel Pattern
```kotlin
@HiltViewModel
class ProMessagesViewModel @Inject constructor(
    private val chatRepository: ChatRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow<MessagesUiState>(MessagesUiState.Loading)
    val uiState: StateFlow<MessagesUiState> = _uiState.asStateFlow()
    
    fun loadChatRooms() {
        viewModelScope.launch {
            _uiState.value = MessagesUiState.Loading
            chatRepository.getProviderChatRooms()
                .catch { _uiState.value = MessagesUiState.Error(it.message) }
                .collect { _uiState.value = MessagesUiState.Success(it) }
        }
    }
}
```

## Navigation

### Jetpack Navigation Compose
```kotlin
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    NavHost(navController, startDestination = "splash") {
        // Auth flow
        navigation("auth", "phone") {
            composable("phone") { PhoneAuthScreen() }
            composable("verify/{phone}") { VerifyPhoneScreen() }
        }
        // Main app
        navigation("main", "home") {
            composable("home") { HomeScreen() }
            composable("search") { SearchScreen() }
            composable("bookings") { BookingsScreen() }
            composable("chat") { ChatListScreen() }
            composable("profile") { ProfileScreen() }
        }
        // Pro dashboard
        navigation("pro", "dashboard") {
            composable("dashboard") { ProDashboardScreen() }
            composable("jobs") { ProJobsScreen() }
            composable("schedule") { ProScheduleScreen() }
            composable("earnings") { ProEarningsScreen() }
            composable("messages") { ProMessagesScreen() }
            composable("profile") { ProProfileScreen() }
        }
    }
}
```

## Testing Strategy

### Unit Tests
- ViewModel logic
- Repository methods
- UseCase implementations
- Data transformations

### Integration Tests
- API calls
- Database operations
- Repository integration

### UI Tests
- Compose UI testing
- Navigation flows
- User interactions

## Performance Considerations

- **Pagination**: Use Supabase pagination for large lists
- **Caching**: Room database for offline access
- **Image Optimization**: Coil with caching, resize on load
- **Lazy Loading**: LazyColumn for efficient list rendering
- **Coroutines**: Proper coroutine scope management

## Security

- **API Keys**: Store in local.properties
- **Sensitive Data**: EncryptedSharedPreferences for tokens
- **SSL Pinning**: For production
- **Input Validation**: Sanitize all user inputs
- **Row Level Security**: Supabase RLS policies

## Deployment

- **Build Variants**: Debug, Release
- **Code Signing**: Keystore management
- **Play Store**: Prepare listing, screenshots, privacy policy
- **Crashlytics**: Firebase Crashlytics for crash reporting
- **Analytics**: Firebase Analytics

## Additional Requirements

1. **Material 3 Design**: Follow Material Design 3 guidelines
2. **Accessibility**: Support screen readers, proper contrast
3. **Localization**: English and Filipino (Tagalog)
4. **Dark Mode**: Support system dark theme
5. **Offline Support**: Cache critical data for offline viewing
6. **Push Notifications**: FCM for booking updates, new messages

## Deliverables

1. Complete Android project with all features implemented
2. Supabase database schema and RLS policies
3. API documentation
4. Unit and integration tests
5. UI/UX mockups
6. Deployment guide
7. User documentation

---

This prompt provides a comprehensive blueprint for rebuilding the SerbisyoHub PH app as a native Kotlin Android application, covering architecture, database schema, features, and implementation details.