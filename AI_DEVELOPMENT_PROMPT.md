# SerbisyoHub PH - AI Development Prompt

## Project Overview
SerbisyoHub PH is a service marketplace mobile application built with Flutter that connects Filipino service providers (pros) with customers. The app features phone authentication, EKYC verification, service bookings, real-time chat, and a comprehensive pro dashboard.

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: StatefulWidget with setState
- **Navigation**: GoRouter
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **UI Components**: Custom widgets with AppTheme
- **Image Handling**: image_picker for uploads
- **Logging**: Custom LoggingService

### Backend (Supabase)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Authentication**: Phone-based OTP via Supabase Auth
- **Storage**: For profile photos, service images, documents
- **Realtime**: For chat messages and notifications

## Project Structure

```
lib/
├── auth/
│   ├── phone_auth/
│   ├── post_auth_navigation_flow.dart
│   └── supabase_auth/
├── backend/
│   └── supabase/
├── components/
│   ├── back_button/
│   ├── categories_widget/
│   └── categoriesgrid/
├── custom_code/
│   ├── actions/
│   └── widgets/
├── main/
│   ├── messages/
│   │   ├── messages_widget.dart
│   │   └── messages_model.dart
│   ├── profile/
│   │   └── profile_widget.dart
│   └── pro_dashboard/
│       ├── pro_dashboard_widget.dart
│       ├── edit_profile_widget.dart
│       ├── service_history_widget.dart
│       ├── reviews_ratings_widget.dart
│       ├── help_support_widget.dart
│       ├── about_widget.dart
│       └── create_service_widget.dart
├── pages/
│   ├── chat_page/
│   ├── edit_profile/
│   ├── settings/
│   └── pro_verification/
├── services/
│   ├── logging_service.dart
│   └── pro_bookings_service.dart
├── theme/
│   └── app_theme.dart
├── router/
│   └── app_router.dart
├── app_state.dart
├── index.dart
└── main.dart
```

## Database Schema

### Key Tables

1. **profiles**
   - id (UUID, PK, auth.uid())
   - email, phone, first_name, last_name, display_name
   - photo_url, bio
   - role ('client' or 'pro')
   - verification_status ('unverified', 'pending', 'verified', 'rejected')
   - is_verified, is_face_verified, is_profile_complete
   - created_at, updated_at

2. **service_listings**
   - id (INTEGER, PK, auto-increment)
   - pro_id (UUID, FK -> profiles.id)
   - title, description, category
   - base_rate, rate_unit
   - location, photos (array)
   - availability (JSON)
   - rating_avg, rating_count
   - is_active
   - created_at, updated_at

3. **bookings**
   - id (UUID, PK)
   - client_id (UUID, FK -> profiles.id)
   - service_id (INTEGER, FK -> service_listings.id)
   - pro_id (UUID, FK -> profiles.id)
   - status ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')
   - scheduled_date, scheduled_time, duration
   - location, notes, total_amount
   - created_at, updated_at

4. **chat_rooms**
   - id (UUID, PK)
   - client_id (UUID, FK -> profiles.id)
   - provider_id (INTEGER, FK -> service_listings.id)
   - provider_name, provider_photo
   - last_message, last_message_time
   - unread_count, unread_provider_count
   - last_message_id (UUID, FK -> chat_messages.id)
   - created_at, updated_at

5. **chat_messages**
   - id (UUID, PK)
   - chat_room_id (UUID, FK -> chat_rooms.id)
   - sender_id (UUID, FK -> profiles.id)
   - content, message_type
   - created_at

6. **notifications**
   - id (UUID, PK)
   - user_id (UUID, FK -> profiles.id)
   - type, title, body, data (JSON)
   - is_read
   - created_at

7. **payment_methods**
   - id (UUID, PK)
   - user_id (UUID, FK -> profiles.id)
   - type, provider, account_number
   - is_default
   - created_at

8. **reviews**
   - id (UUID, PK)
   - booking_id, service_id, pro_id, client_id
   - rating (1-5), comment
   - created_at

## Key Features

### 1. Authentication Flow
- Phone number input with country code (+63 for Philippines)
- OTP verification via SMS
- Post-auth navigation based on user role and verification status
- Profile completion for new users
- EKYC verification for pro users

### 2. EKYC Verification (Pro Users)
- Document scanning (ID capture)
- Face verification (compare live face with ID photo)
- 4-state lifecycle: Unverified → Pending → Verified/Rejected
- Reviewing state during verification process

### 3. Main App (Client View)
- **Home**: Featured services, categories
- **Search**: Search/filter services by category, location, rating
- **Bookings**: View booking history and status
- **Chat**: Chat with service providers
- **Profile**: Edit profile, view reviews, settings

### 4. Pro Dashboard
- **Jobs Tab**: View pending job requests, accept/reject
- **Schedule Tab**: View scheduled jobs, mark as complete
- **Earnings Tab**: Calculate earnings from completed jobs, show summary
- **Messages Tab**: Chat rooms with customers (dynamic, real-time)
- **Profile Tab**: 
  - Edit profile with photo upload
  - Service history
  - Reviews & ratings
  - Help & support
  - About
  - Create a service

### 5. Service Listings
- Create service with image upload
- Category selection
- Base rate and rate unit
- Location
- Availability schedule
- Photos array

### 6. Chat System
- Real-time messaging via Supabase Realtime
- Chat rooms per booking
- Unread count tracking (separate for client and provider)
- Last message preview
- Timestamp formatting

### 7. Reviews & Ratings
- Submit review after booking completion
- Display reviews on service listing
- Rating distribution breakdown
- Average rating calculation

## Important Files

### Core Files
- `lib/main.dart`: App entry point
- `lib/index.dart`: Exports all widgets
- `lib/router/app_router.dart`: GoRouter configuration
- `lib/app_state.dart`: Global app state

### Authentication
- `lib/auth/phone_auth/`: Phone authentication flow
- `lib/auth/post_auth_navigation_flow.dart`: Post-auth routing logic

### Pro Dashboard
- `lib/main/pro_dashboard/pro_dashboard_widget.dart`: Main pro dashboard with all tabs
- `lib/main/pro_dashboard/edit_profile_widget.dart`: Pro edit profile (ProEditProfileWidget)
- `lib/main/pro_dashboard/service_history_widget.dart`: Service history
- `lib/main/pro_dashboard/reviews_ratings_widget.dart`: Reviews display
- `lib/main/pro_dashboard/help_support_widget.dart`: Help & support
- `lib/main/pro_dashboard/about_widget.dart`: About page
- `lib/main/pro_dashboard/create_service_widget.dart`: Create service listing

### Services
- `lib/services/pro_bookings_service.dart`: Booking operations for pros
- `lib/services/logging_service.dart`: Logging utility

### Database
- `database/create_chat_tables.sql`: Chat tables schema
- `database/create_notifications_table.sql`: Notifications schema
- `database/create_payment_methods_table.sql`: Payment methods schema
- `database/add_provider_verification_fields.sql`: Verification fields
- `database_schema.sql`: Full database schema

## Routing

### Route Naming Convention
- All widgets have `static const String routeName` and `static const String routePath`
- Route names use PascalCase (e.g., 'ProEditProfile', 'CreateService')
- Route paths use kebab-case (e.g., '/pro/edit-profile', '/pro/create-service')

### Key Routes
- `/phoneAuth`: Phone authentication
- `/phoneVerifyUser`: OTP verification
- `/eKYCBegin`: EKYC verification start
- `/pro-verify-doc`: Document upload
- `/pro-verify-face`: Face verification
- `/pro-dashboard`: Pro dashboard main
- `/pro/edit-profile`: Pro edit profile
- `/pro/service-history`: Service history
- `/pro/reviews-ratings`: Reviews & ratings
- `/pro/help-support`: Help & support
- `/pro/about`: About
- `/pro/create-service`: Create service
- `/chatPage`: Chat page with parameters

## Important Patterns

### Supabase Queries
- Use `.select()` with field selection
- Use `.eq()` for equality filters
- Use `.filter()` for complex filters (e.g., `.filter('provider_id', 'in', serviceIds)`)
- Use `.order()` for sorting
- Use `.maybeSingle()` for optional single results
- Handle foreign key relationships carefully - FK hints require actual FK constraints

### State Management
- StatefulWidget with setState for local state
- setState for UI updates
- isLoading boolean for loading states
- mounted check before setState

### Navigation
- Use `context.pushNamed(routeName)` for named routes
- Use `context.pushNamed(routeName, queryParameters: {...})` for parameters
- Use `context.go('/')` for navigation to root

### Error Handling
- Try-catch blocks for async operations
- SnackBar for user-facing error messages
- LoggingService.error for logging with tags

### Image Uploads
- Use image_picker for selecting images
- Upload to Supabase Storage
- Store returned URLs in database

## Current Issues & Fixes

### Pro Messages Widget Freezing
**Issue**: Screen froze when loading messages due to:
1. Comparing UUID `userId` to INTEGER `provider_id` (type mismatch)
2. Missing FK constraint on `chat_rooms.client_id`

**Fix**:
1. Fetch service listing IDs first: `service_listings.select('id').eq('pro_id', userId)`
2. Filter chat rooms by service IDs: `.filter('provider_id', 'in', serviceIds)`
3. Add FK constraint: `ALTER TABLE chat_rooms ADD CONSTRAINT chat_rooms_client_id_fkey FOREIGN KEY (client_id) REFERENCES profiles(id)`
4. Add columns: `unread_provider_count`, `last_message_id`

### Route Registration Errors
**Issue**: Unknown route name errors when navigating

**Fix**:
1. Ensure widget has `static const String routeName` and `routePath`
2. Add GoRoute entry in `app_router.dart`
3. Import widget in `app_router.dart`
4. Export widget in `index.dart`

### Naming Conflicts
**Issue**: Two widgets with same name (EditProfileWidget)

**Fix**:
- Rename pro version to `ProEditProfileWidget`
- Update route name to 'ProEditProfile'
- Update all references

## Development Guidelines

### When Adding New Features
1. Create widget file in appropriate directory
2. Add `routeName` and `routePath` static constants
3. Add GoRoute entry in `app_router.dart`
4. Import widget in `app_router.dart`
5. Export widget in `index.dart`
6. Update navigation calls with correct route name
7. Add database migrations if needed
8. Add RLS policies for new tables

### When Modifying Database
1. Create SQL migration file in `database/` directory
2. Add FK constraints where appropriate
3. Add RLS policies for security
4. Test with Supabase SQL Editor
5. Update related queries in code

### When Adding Supabase Queries
1. Check column types (UUID vs INTEGER)
2. Verify FK constraints exist before using join hints
3. Use separate queries if FK hints don't work
4. Handle null responses gracefully
5. Add error logging

### Code Style
- Follow Flutter/Dart conventions
- Use const constructors where possible
- Format code with dart format
- Add comments for complex logic
- Use meaningful variable names

## Testing Checklist

Before marking a feature complete:
- [ ] Route is registered in app_router.dart
- [ ] Widget is exported in index.dart
- [ ] Navigation works correctly
- [ ] Database queries execute without errors
- [ ] RLS policies are in place
- [ ] Loading states display correctly
- [ ] Error handling works
- [ ] UI is responsive
- [ ] Images load correctly
- [ ] Real-time updates work (if applicable)

## Common Commands

### Run the app
```bash
flutter run
```

### Build for release
```bash
flutter build apk
flutter build appbundle
```

### Format code
```bash
dart format .
```

### Analyze code
```bash
flutter analyze
```

### Run tests
```bash
flutter test
```

## External APIs

### PSGC API
- Endpoint: https://psgc.gitlab.io/api/
- Purpose: Philippine geographic data (regions, provinces, cities)
- Used for location selection

## Security Notes

- API keys stored in environment variables
- RLS policies enabled on all tables
- Sensitive data encrypted in database
- Phone numbers validated before OTP
- Document images stored in secure storage

## Future Enhancements

- Payment integration (GCash, Maya)
- Push notifications (FCM)
- Offline support
- Video calls for consultations
- Advanced search filters
- Service provider analytics
- Customer loyalty program

---

## Instructions for AI Assistant

When working on this project:

1. **Always** check if a route exists before adding navigation
2. **Always** verify database schema before writing queries
3. **Always** add RLS policies for new tables
4. **Always** handle null responses from Supabase
5. **Always** use proper type checking (UUID vs INTEGER)
6. **Always** add error logging with LoggingService
7. **Always** test with both client and pro user flows
8. **Always** check for naming conflicts with existing widgets
9. **Always** update imports and exports when adding new files
10. **Always** follow the established patterns in the codebase

## Current Task Context

The Pro Messages page has been made dynamic with:
- Real-time chat room loading from Supabase
- Customer profile fetching
- Last message display
- Unread count tracking
- Navigation to chat page
- Pull-to-refresh support
- Empty state handling

The Create Service page is fully functional with:
- Form validation
- Image upload to Supabase Storage
- Category selection
- Database insertion
- Navigation from profile

All pro dashboard sub-pages are complete and integrated.
