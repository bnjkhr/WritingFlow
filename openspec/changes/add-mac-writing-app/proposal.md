# Change: Add Mac Writing App with AI-Powered Summarization

## Why
Create a focused macOS writing application that helps writers overcome creative blocks through structured 15-minute writing sessions with AI-powered insights and summaries.

## What Changes
- Create new macOS application with SwiftUI interface
- Implement 15-minute timer with activity-based pausing
- Add backspace blocking during active writing sessions
- Integrate Apple Foundation Models for text summarization
- Build session history and rewind functionality
- Establish Clean Architecture with 4-layer separation

## Impact
- Affected specs: New capability `writing-session`
- Affected code: New project structure with Domain/Data/Presentation/Infrastructure layers
- Dependencies: Foundation Models framework (macOS 15.0+)
- Target platform: macOS only (initially)