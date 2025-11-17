# Project Context

## Purpose

**WritingFlow** is a focused macOS writing application designed for distraction-free creative writing sessions with AI-powered summarization.

The app provides:
- **15-minute focused writing sessions** with backspace disabled to encourage forward momentum
- **Activity-based pausing** that automatically pauses the timer when user stops typing
- **AI-powered summaries** using Apple Foundation Models to provide insights after each session
- **Rewind functionality** to review and reflect on completed writing sessions

**Target Audience**: Writers, journalers, and creative professionals who want to overcome writer's block through structured, timed writing sessions.

## Tech Stack

### Core Technologies
- **Swift** 5.9+ (primary language)
- **SwiftUI** 5.0+ (declarative UI framework for macOS)
- **SwiftData** (macOS 15.0+ persistence layer)
- **Foundation Models** (Apple Intelligence for text summarization)
- **@Observable** macro (macOS 15.0+ state management)
- **macOS SDK** 15.0+ minimum deployment target
- **Xcode** 15.0+ (development environment)

### Development & Quality Tools
- **SwiftLint** with custom rules for code quality enforcement
- **Git** for version control

### Notable Decisions
- **Zero external dependencies** - Built entirely with native Apple frameworks
- **SwiftData for persistence** - Type-safe, compile-time validated data storage
- **Foundation Models integration** - On-device AI processing for privacy
- **Clean Architecture** - Framework-independent domain layer for testability

## Project Conventions

### Code Style

#### SwiftLint Configuration
- **Function body length**: 60 lines warning, 100 lines error
- **Cyclomatic complexity**: 15 warning, 25 error
- **Architectural rule**: No SwiftData imports in Domain layer

#### Naming Conventions
- **Domain entities**: Plain names (e.g., `WritingSession`, `TextContent`)
- **SwiftData entities**: Suffix with `Entity` (e.g., `WritingSessionEntity`)
- **Use cases**: Verb-based names (e.g., `StartWritingSessionUseCase`, `GenerateSummaryUseCase`)
- **Repositories**: Protocol name + `Protocol` suffix (e.g., `WritingSessionRepositoryProtocol`)
- **Repository implementations**: `SwiftData` prefix (e.g., `SwiftDataWritingSessionRepository`)
- **Stores**: Suffix with `Store` (e.g., `WritingSessionStore`)

#### Code Organization
- **Import statements**: Grouped and sorted (Foundation first, then SwiftUI, then other frameworks)
- **File structure**: One primary type per file
- **Ordering**: MARK comments for Properties → Initializer → Public Methods → Private Methods

### Architecture Patterns

#### Clean Architecture (4 Layers)
Strict dependency rule: Dependencies point inward only

1. **Presentation Layer** (`/Presentation/`)
   - SwiftUI views organized by feature (WritingSession, History, Settings)
   - Stores for state management (`WritingSessionStore`, `TimerStore`)
   - Reusable components in `/Components/`
   - Services for UI-specific logic (e.g., `TimerStateManager`)

2. **Domain Layer** (`/Domain/`)
   - Domain entities (pure Swift structs/enums, no framework dependencies)
   - Use cases across domains (WritingSession, Timer, Summary, History)
   - Repository protocols (abstraction for data access)
   - Domain services (e.g., `ActivityDetector`, `TimerEngine`)
   - 100% framework-independent and testable

3. **Data Layer** (`/Data/`)
   - SwiftData @Model entities for persistence
   - Repository implementations (SwiftDataWritingSessionRepository, etc.)
   - Bidirectional mappers between Domain ↔ Entity
   - Schema migrations

4. **Infrastructure Layer** (`/Infrastructure/`)
   - Dependency injection (`DependencyContainer`)
   - Foundation Models integration (`SummaryService`)
   - Feature flags (`FeatureFlagService`)
   - Seed data and utilities

#### Key Patterns
- **Use Case Pattern**: Each business operation = one use case with single responsibility
- **Repository Pattern**: Data access abstraction with protocol in Domain, implementation in Data
- **Dependency Injection**: Constructor injection throughout, central `DependencyContainer`
- **Mapper Pattern**: Bidirectional conversion between domain models and persistence entities
- **@Observable State Management**: Fine-grained reactivity for stores

### Testing Strategy

#### Test Coverage
- **Test Targets**: `WritingFlowTests` (unit & integration), `WritingFlowUITests` (UI automation)
- **Mock Strategy**: Mock repositories for testing use cases in isolation
- **Domain Layer**: 100% framework-independent ensures full testability
- **Mapper Tests**: Verify bidirectional domain ↔ entity conversions

### Git Workflow

#### Branching Strategy
- **Main branch**: `main` (production-ready code)
- **Feature branches**: Used for development

#### Commit Conventions
- **feat**: New features
- **fix**: Bug fixes
- **refactor**: Code refactoring
- **docs**: Documentation updates
- Descriptive messages focusing on user-facing changes

## Domain Context

### Core Domain Concepts

#### Writing Sessions
- **WritingSession**: A timed writing session with start/end times and content
- **SessionState**: Active → Paused → Completed lifecycle
- **TextContent**: The actual written content with metadata (word count, typing speed)
- **ActivityDetection**: Monitoring user typing to pause timer automatically

#### Timer Management
- **TimerEngine**: Core timer logic with configurable duration (15 minutes default)
- **TimerState**: Running → Paused → Completed → Expired
- **ActivityDetector**: Monitors keyboard input to detect user activity
- **BackspaceBlocker**: Prevents backward deletion during active writing

#### AI-Powered Features
- **SummaryGeneration**: Using Foundation Models to create session summaries
- **InsightExtraction**: Identifying themes, mood, and writing patterns
- **RewindFunction**: Review session content with AI-generated insights

#### Session History
- **SessionHistory**: Collection of past writing sessions
- **SessionAnalytics**: Statistics on writing habits and productivity
- **ContentSearch**: Search through past writing sessions

### Domain Rules

#### Writing Session Logic
- Backspace key is disabled during active writing to encourage forward momentum
- Timer automatically pauses when no typing activity is detected for 30 seconds
- Session content is auto-saved continuously during writing
- Sessions can be extended or shortened based on user preference

#### Activity Detection
- Monitor keyboard input to detect active writing
- Consider mouse movement and app focus as secondary activity indicators
- Grace period of 30 seconds before pausing timer
- Visual and haptic feedback when timer pauses due to inactivity

#### AI Integration
- All AI processing happens on-device using Foundation Models
- Summaries are generated after session completion
- User can request additional insights or re-generate summaries
- AI content is stored alongside original writing for comparison

## Important Constraints

### Technical Constraints
- **macOS 15.0+ minimum deployment target** (for Foundation Models)
- **No external dependencies policy** (all native Apple frameworks only)
- **SwiftData persistence only** (no CoreData, no Realm)
- **Mac only** (no iOS/iPadOS optimization initially)
- **Local-first architecture** (all data stored locally)

### Business Constraints
- **Mac App Store compliance required**
- **Privacy-focused** (all data stored locally, AI processing on-device)
- **No analytics or tracking** (respect user privacy)
- **Accessibility support** (VoiceOver, keyboard navigation)

### Performance Constraints
- **Database size**: Optimized for writing sessions (text content is primary data)
- **UI responsiveness**: 60fps target during typing
- **Memory usage**: Efficient text handling for long writing sessions
- **Battery efficiency**: Minimal background processing

### Architectural Constraints
- **Domain layer purity**: ZERO macOS framework imports in `/Domain/`
- **SwiftData isolation**: Only in `/Data/` and `/Infrastructure/` layers
- **Use case pattern**: All business logic must go through use cases
- **Repository abstraction**: No direct ModelContext access in Domain layer

## External Dependencies

### Native Apple Frameworks
- **SwiftUI** - UI framework for macOS
- **SwiftData** - Persistence layer
- **Foundation Models** - Apple Intelligence for text processing
- **Foundation** - Core utilities
- **AppKit** - macOS-specific UI components (where needed)

### Services & APIs
- **Apple Intelligence** (Foundation Models) - On-device AI processing
- **No cloud services** (privacy-focused, local-only)
- **No analytics services** (privacy-focused)
- **No crash reporting** (using Apple's default)

### Future Dependencies (Planned)
- **CloudKit** - For cross-device sync (optional feature)
- **StoreKit 2** - For potential premium features
- **WidgetKit** - For writing session widgets

### Internal Service Dependencies
All internal services are dependency-injected via `DependencyContainer`:
- `SummaryService` - Foundation Models operations
- `ActivityDetector` - Typing activity monitoring
- `TimerEngine` - Session timer management
- `BackspaceBlocker` - Keyboard input filtering