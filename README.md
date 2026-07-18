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
- **Auth**: JWT-based auth (email/password, biometric)
- **Backend Client**: Dio (REST)
- **Maps**: Google Maps / Google Places
- **ML Kit**: Face detection, document scanning
- **UI**: Lottie, Flutter Animate, Smooth Page Indicator, Skeletonizer
- **Push Notifications**: Firebase Cloud Messaging

### Backend API (Django)
- **Framework**: Django REST Framework
- **Database**: PostgreSQL (primary) + MongoDB (chat, logs via Djongo)
- **Cache**: Redis
- **Auth**: JWT (SimpleJWT)
- **CMS**: Wagtail

### Firebase
- **Cloud Messaging**: Push notifications
- **Storage**: File uploads

## Project Structure

```
├── android/                    # Android native configuration
├── ios/                        # iOS native configuration
├── web/                        # Web app entry point
├── lib/
│   ├── main.dart               # App entry point
│   ├── index.dart              # Page exports
│   ├── api/                    # REST API client (Dio)
│   ├── auth/                   # Auth providers (JWT)
│   ├── backend/                # Local SQLite backend integration
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
├── firebase/                   # Firebase config & Cloud Functions
├── assets/                     # Images, fonts, animations, PDFs, videos, JSON
└── test/                       # Flutter tests
```

## Getting Started

### Prerequisites
- Flutter 3.x SDK
- Django backend running (see `shph-api/` in the main repo)

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
# Flutter (.env)
API_BASE_URL=https://api.serbisyohubph.com
FIREBASE_API_KEY=...
FIREBASE_PROJECT_ID=...
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
- **Authentication**: Email/password, biometric login
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
