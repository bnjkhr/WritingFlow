## ADDED Requirements

### Requirement: Writing Session Management
The system SHALL provide timed writing sessions with configurable duration and automatic state management.

#### Scenario: Start 15-minute writing session
- **WHEN** user clicks "Start Writing" button
- **THEN** system SHALL start a 15-minute timer
- **AND** display timer countdown in real-time
- **AND** enable text input area for writing

#### Scenario: Pause session due to inactivity
- **WHEN** user stops typing for 30 seconds during active session
- **THEN** system SHALL automatically pause the timer
- **AND** display visual notification about pause
- **AND** allow user to resume when ready

#### Scenario: Complete writing session
- **WHEN** timer expires or user manually ends session
- **THEN** system SHALL save all written content
- **AND** transition to session summary view
- **AND** offer AI-powered summary generation

### Requirement: Backspace Blocking
The system SHALL prevent backward deletion during active writing to encourage forward momentum.

#### Scenario: Block backspace during active writing
- **WHEN** user presses backspace key during active writing session
- **THEN** system SHALL ignore the backspace input
- **AND** continue with forward-only typing
- **AND** provide visual feedback about this restriction

#### Scenario: Allow editing after session completion
- **WHEN** writing session is completed
- **THEN** system SHALL enable normal text editing
- **AND** allow backspace and other editing functions
- **AND** provide full text manipulation capabilities

### Requirement: Activity Detection
The system SHALL monitor user typing activity to manage timer state automatically.

#### Scenario: Detect typing activity
- **WHEN** user types any character during active session
- **THEN** system SHALL reset inactivity timer
- **AND** continue session timer without interruption
- **AND** update last activity timestamp

#### Scenario: Handle inactivity timeout
- **WHEN** no typing activity detected for 30 seconds
- **THEN** system SHALL pause the session timer
- **AND** show inactivity notification
- **AND** wait for user interaction to resume

### Requirement: AI-Powered Summary Generation
The system SHALL use Apple Foundation Models to generate intelligent summaries of writing sessions.

#### Scenario: Generate session summary
- **WHEN** writing session is completed
- **THEN** system SHALL offer to generate AI summary
- **AND** use Foundation Models to analyze content
- **AND** provide concise summary with key insights

#### Scenario: Extract writing insights
- **WHEN** AI summary is requested
- **THEN** system SHALL identify themes and patterns
- **AND** analyze writing style and mood
- **AND** provide actionable insights for improvement

### Requirement: Rewind Functionality
The system SHALL provide review capabilities for completed writing sessions with AI-generated insights.

#### Scenario: Review past session
- **WHEN** user selects a completed session from history
- **THEN** system SHALL display original written content
- **AND** show AI-generated summary alongside
- **AND** provide insights and analytics

#### Scenario: Compare writing patterns
- **WHEN** user views multiple sessions
- **THEN** system SHALL show writing statistics
- **AND** compare session lengths and productivity
- **AND** highlight trends in writing habits

### Requirement: Session Persistence
The system SHALL reliably store and retrieve writing sessions with all associated metadata.

#### Scenario: Auto-save during writing
- **WHEN** user is actively writing
- **THEN** system SHALL continuously save content
- **AND** preserve session state and timer information
- **AND** prevent data loss on app crash

#### Scenario: Retrieve session history
- **WHEN** user accesses session history
- **THEN** system SHALL display list of past sessions
- **AND** show session dates, durations, and word counts
- **AND** allow filtering and searching

### Requirement: User Interface
The system SHALL provide a clean, distraction-free interface optimized for focused writing.

#### Scenario: Minimal writing interface
- **WHEN** user is in active writing session
- **THEN** system SHALL display only essential controls
- **AND** hide distracting interface elements
- **AND** provide full-screen writing mode option

#### Scenario: Responsive timer display
- **WHEN** timer is running
- **THEN** system SHALL show remaining time prominently
- **AND** update display every second
- **AND** use visual indicators for time pressure