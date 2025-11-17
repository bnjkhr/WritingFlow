# WritingFlow

A focused macOS writing application with AI-powered summarization for distraction-free creative writing sessions.

## Features

- **15-minute focused writing sessions** with backspace disabled to encourage forward momentum
- **Activity-based pausing** that automatically pauses the timer when user stops typing
- **AI-powered summaries** using Apple Foundation Models to provide insights after each session
- **Rewind functionality** to review and reflect on completed writing sessions
- **Session history** with analytics and writing pattern tracking

## Tech Stack

- **Swift** 5.9+ with **SwiftUI** for macOS
- **SwiftData** for local data persistence
- **Foundation Models** (Apple Intelligence) for AI-powered features
- **Clean Architecture** with 4-layer separation
- **Zero external dependencies** - 100% native Apple frameworks

## Requirements

- macOS 15.0+
- Xcode 15.0+
- Apple Intelligence compatible Mac

## Getting Started

1. Clone this repository
2. Open `WritingFlow.xcodeproj` in Xcode
3. Build and run on your Mac

## Architecture

The app follows Clean Architecture principles with four distinct layers:

- **Presentation Layer**: SwiftUI views and state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: SwiftData persistence and repositories
- **Infrastructure Layer**: External services and dependency injection

## Privacy

All data is stored locally on your Mac. AI processing happens on-device using Apple Foundation Models, ensuring your writing remains private.

## License

[License information to be added]

---

*Built with ❤️ for writers who want to overcome creative blocks*