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
- **Real-time**: WebSocket (Django Channels) for chat, WebRTC for video calls
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
│   │   ├── models/             # API response models (fromJson/toJson)
│   │   └── resources/          # API resource clients (auth, chat, services, etc.)
│   ├── auth/                   # Auth providers (JWT)
│   ├── backend/                # Local SQLite backend integration
│   ├── components/             # Shared UI widgets
│   ├── flutter_flow/           # FF-generated utilities
│   ├── models/                 # Domain data models
│   ├── pages/                  # Screen implementations
│   │   ├── main/               # Core tabs (Home, Category, Bookings, Messages, Profile)
│   │   ├── pro_verification/   # EKYC, document scan, face verification
│   │   ├── call/               # Call UI (call page, incoming call overlay)
│   │   └── ...                 # Individual pages
│   ├── router/                 # go_router configuration
│   ├── services/               # Business logic services
│   │   ├── call/               # WebRTC call pipeline (controller, signaling, peer, ICE config)
│   │   ├── chat_service.dart   # Chat WebSocket routing
│   │   ├── websocket_service.dart  # Real-time WebSocket client (Django Channels)
│   │   └── ...                 # Other services (auth, bookings, sound, PDF, etc.)
│   ├── theme/                  # App theme & styling
│   ├── utils/                  # Shared utilities (formatters, geo_utils, etc.)
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

# WebRTC TURN credentials (optional, for NAT traversal)
# Pass via --dart-define at build time:
#   --dart-define=SHPH_TURN_USERNAME=... --dart-define=SHPH_TURN_CREDENTIAL=...
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
- **Chat**: Real-time messaging via WebSocket (Django Channels) with typing indicators and read receipts
- **Video Calls**: 1:1 WebRTC video calls with mute, camera toggle, and camera switch
  - Signaling rides over the existing chat WebSocket (no separate connection)
  - ICE/STUN/TURN configuration with credentials via `--dart-define`
  - Full call state machine: idle → outgoing → ringing → connecting → connected → ended
  - Incoming call overlay for background calls
- **Payments**: Card and e-wallet payment method management
- **E-KYC**: Identity verification with document scanning and face verification
- **Pro Dashboard**: Provider profile management, service history, reviews
- **Notifications**: Real-time booking and chat notifications
- **Reviews**: Rate and review completed services
- **Favorites**: Bookmark services for later

## Testing

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/utils/formatters_test.dart      # Formatters utilities
flutter test test/call_controller_test.dart        # WebRTC call state machine
flutter test test/call_signaling_test.dart         # Call signaling over WebSocket
flutter test test/call_ice_config_test.dart        # ICE/STUN/TURN config
flutter test test/websocket_config_test.dart       # WebSocket URL & token config
flutter test test/services/                        # Service tests (sound, gemini, etc.)

# Analyze and format
dart format lib/
flutter analyze lib/
```

## License

Private project.
