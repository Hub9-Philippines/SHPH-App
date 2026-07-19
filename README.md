# SerbisyoHub PH 🇵🇭

A service provider marketplace mobile application built for Filipinos. Clients can find and book local service providers for home services, while professionals can list their services and manage their bookings.

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Stable, production-ready code. |
| `develop` | Active development — integration branch for all features. |
| `feature/booking-flow-system` | Booking flow feature work (status sheet, polyline, address). |
| `feature/pol` | Paul's working branch for the Mobile Port plan (see `docs/mobile_port_plan_2026-07.md`). |

## Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.x (Dart 3.0+, Android, iOS, Web)
- **State Management**: Provider
- **Routing**: go_router
- **Auth**: Supabase Auth (Google Sign-In, Apple Sign-In, email/password)
- **Backend Client**: Dio (REST), supabase_flutter (Realtime, Storage)
- **Maps**: Google Maps / Google Places
- **ML Kit**: Face detection, document scanning
- **UI**: Lottie, Flutter Animate, Smooth Page Indicator, Skeletonizer
- **Push Notifications**: Firebase Cloud Messaging

### Backend API (Node.js)
- **Runtime**: Node.js (TypeScript)
- **Framework**: Express.js
- **Database**: PostgreSQL (primary) via TypeORM
- **Cache**: Redis (ioredis)
- **Auth**: JWT (jsonwebtoken, bcrypt)
- **Validation**: Zod
- **Security**: Helmet, CORS

### Backend (Supabase)
- **Auth**: User management, session handling, RLS policies
- **Database**: PostgreSQL (profiles, service_listings, bookings, reviews, messages, notifications, favorites, addresses, categories)
- **Storage**: Document uploads, profile photos
- **Realtime**: Chat, notifications

### Infrastructure (AWS)
- **Orchestration**: ECS Fargate (via CDK)
- **Database**: RDS PostgreSQL 15
- **Cache**: ElastiCache (Redis)
- **CI/CD**: Docker → ECR → ECS

### Firebase
- **Cloud Functions**: Serverless API management, push notifications
- **Firestore**: Secondary data store
- **Storage**: File upload rules

## Project Structure

```
├── android/                    # Android native configuration
├── ios/                        # iOS native configuration
├── web/                        # Web app entry point
├── lib/
│   ├── main.dart               # App entry point
│   ├── index.dart              # Page exports
│   ├── api/                    # REST API client (Dio)
│   ├── auth/                   # Auth providers (Supabase)
│   ├── backend/                # Supabase backend integration
│   ├── components/             # Shared UI widgets
│   ├── flutter_flow/           # FF-generated utilities
│   ├── models/                 # Data models
│   ├── pages/                  # Screen implementations
│   │   ├── main/               # Core tabs (Home, Category, Bookings, Messages, Profile)
│   │   ├── pro_verification/   # EKYC, document scan, face verification
│   │   └── ...                 # Individual pages
│   ├── router/                 # go_router configuration
│   ├── services/               # Business logic services
│   ├── theme/                  # App theme & styling
│   └── widgets/                # Reusable widgets
├── database/                   # SQL migration scripts
├── firebase/                   # Firebase config & Cloud Functions
├── assets/                     # Images, fonts, animations, PDFs, videos, JSON
└── test/                       # Flutter tests
```

## Database Schema (Supabase)

| Table | Purpose |
|---|---|
| `profiles` | User profiles (clients & providers) with verification status |
| `service_listings` | Services offered by providers |
| `categories` | Service categories (cleaning, plumbing, electrical, etc.) |
| `bookings` | Service booking records with status tracking |
| `reviews` | Ratings & reviews for services |
| `messages` | Chat messages between users |
| `notifications` | Push/in-app notifications |
| `favorites` | Saved/bookmarked services |
| `addresses` | Saved user addresses |

Built-in RLS policies protect data per user.

## Getting Started

### Prerequisites
- Flutter 3.x SDK
- Access to the deployed SHPH API
- Firebase project (optional, for push notifications)

### Running the Flutter App

```bash
# Clone the repository
git clone https://github.com/itsmerims/SHPH-App.git
cd SHPH-App

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables

```
# Flutter build-time configuration
SHPH_API_BASE_URL=https://api.serbisyohub.ph
SHPH_WS_URL=wss://serbisyohubph.com/ws
```

## Deployment

### Flutter App
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## App Features

- **Onboarding**: Three-screen intro with animated illustrations
- **Authentication**: Email/password, Google Sign-In, Apple Sign-In
- **Home**: Service discovery, featured listings, search
- **Categories**: 10 service categories with sub-listings
- **Booking**: Full booking flow with date/time selection, address management
- **Chat**: Real-time messaging between clients and providers
- **Payments**: Card and e-wallet payment method management
- **E-KYC**: Identity verification with document scanning and face verification
- **Pro Dashboard**: Provider profile management, service history, reviews
- **Notifications**: Real-time booking and chat notifications
- **Reviews**: Rate and review completed services
- **Favorites**: Bookmark services for later

## License

Private project.
