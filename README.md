# Heartly AI

AI-powered skin analysis and wellness app built with Flutter.

## Features

- 📸 **Skin Analysis** - AI-powered facial analysis with 11 metrics
- 🎨 **Visual Predictions** - See how you'll look in 5 years (worst/best case)
- 👶 **Age Prediction** - Apparent age vs real age comparison
- 🏆 **Social Ranking** - Compare with people your age
- 👯 **Friend Challenges** - Challenge friends to see who has better skin
- 📊 **Progress Tracking** - Track your skin health over time

## Tech Stack

- **Framework:** Flutter 3.19+
- **Language:** Dart 3.0+
- **State Management:** Provider
- **Navigation:** GoRouter
- **Storage:** Hive (local), SharedPreferences
- **APIs:**
  - AILabTools (skin analysis)
  - Replicate (image generation)
  - Microsoft Face API (age prediction)

## Project Structure

```
lib/
├── config/           # Theme, routes, constants
├── models/           # Data models
├── services/         # API and storage services
├── providers/        # State management
├── screens/          # App screens
├── widgets/          # Reusable widgets
├── utils/            # Helpers and utilities
└── main.dart         # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Dart SDK 3.0+
- Android Studio / Xcode (for mobile)
- API keys (see .env.example)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/heartly-ai.git
cd heartly-ai
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create `.env` file from example:
```bash
cp .env.example .env
```

4. Add your API keys to `.env`

5. Run the app:
```bash
flutter run
```

## Environment Variables

Create a `.env` file with:

```
AILABTOOLS_API_KEY=your_key_here
REPLICATE_API_TOKEN=your_token_here
MICROSOFT_FACE_API_KEY=your_key_here
```

## Development

### Run tests
```bash
flutter test
```

### Build for production
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Contributing

This is a private project. Contact the team for contribution guidelines.

## License

Proprietary - All rights reserved.

## Team

- **Brayan Molina** - Founder & Tech Lead
- **Isa (AI Co-founder)** - Business & Marketing Strategy

---

Built with ❤️ by Heartly AI Team
