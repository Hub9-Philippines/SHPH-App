# SerbisyoHub PH — Client App 🇵🇭

> **Client-only app.** Provider tools now live in the standalone **SerbisyoHub Provider** app (`E:\Dev\shph-provider`). This repository no longer contains provider dashboard, earnings, service management, or KYC verification screens.

A service marketplace mobile application for **clients**: discover services, book providers, track jobs, chat, and review. Provider capabilities (job handling, earnings, KYC) were extracted to `shph-provider` per `openspec/changes/split-client-provider-apps`.

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Stable, production-ready code. |
| `develop` | Active development — integration branch for all features. |
| `feature/booking-flow-system` | Booking flow feature work (status sheet, polyline, address). |
| `feature/pol` | Paul's working branch for the Mobile Port plan (see `docs/mobile_port_plan_2026-07.md`). |

## Tech Stack

### Mobile App — Client (Flutter)
- **Framework**: Flutter 3.x (Dart 3.0+, Android, iOS, Web)
- **State Management**: Provider + FFAppState
- **Routing**: go_router (client routes only; provider routes removed)
- **Auth**: SHPH REST API (`ShphAuthManager` / `AuthService`; `provider` role removed — all signups are clients)
- **Backend Client**: Dio (REST) against `https://serbisyohubph.com`
- **Maps**: Google Maps / Google Places
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
├── backend/                    # Node.js Express backend
│   ├── src/
│   │   ├── index.ts            # Server entry point
│   │   ├── routes/             # API routes (auth, users, chat, services)
│   │   ├── middleware/         # Auth middleware, error handler
│   │   ├── services/           # Business logic layer
│   │   ├── types/              # TypeScript type definitions
│   │   └── db/                 # TypeORM data source & entities
│   └── aws/                    # AWS deployment (Dockerfile, CDK, ECS config)
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

## API Endpoints (Express Backend)

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/health` | No | Health check |
| `POST` | `/api/auth/*` | No | Authentication routes |
| `GET/POST/PUT` | `/api/users/*` | JWT | User profile management |
| `GET/POST` | `/api/chat/*` | JWT | Chat & messaging |
| `GET/POST/PUT` | `/api/services/*` | JWT | Service listings & management |

## Getting Started

### Prerequisites
- Flutter 3.x SDK
- Node.js 18+
- PostgreSQL / Supabase project
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

### Running the Backend

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your DATABASE_URL, JWT_SECRET, REDIS_URL

# Start development server
npm run dev
```

### Environment Variables

```
# Backend (.env)
DATABASE_URL=postgresql://user:password@host:5432/shphdb
JWT_SECRET=your-jwt-secret
REDIS_URL=redis://host:6379
PORT=4000
```

## Deployment

### Backend (AWS)
See [backend/aws/README.md](backend/aws/README.md) for ECS Fargate deployment instructions.

### Flutter App
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## App Features (client)

- **Onboarding**: Three-screen intro with animated illustrations
- **Authentication**: Email/password, Google/Apple sign-in (client accounts only)
- **Home / Explore / Categories**: Service discovery, featured listings, search
- **Booking**: Full client booking flow with date/time selection, address management, payment
- **Chat**: Real-time messaging with providers
- **Payments**: Card and e-wallet management, wallet
- **Notifications**: Real-time booking and chat notifications
- **Reviews / Favorites**: Rate services, bookmark providers

> Provider features (Jobs, Schedule, Earnings, My Services, Analytics, Bids, KYC) now ship in `shph-provider`.

## License

Private project.
