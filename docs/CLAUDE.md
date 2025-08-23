# TeaElephant Project Documentation for AI Assistants

## Project Overview
TeaElephant is a **home-use iOS application** for managing tea collections with AR visualization capabilities. This is NOT a production app for distribution, allowing for relaxed deployment requirements (iOS 18+, hardcoded URLs are acceptable) while maintaining production-quality code architecture.

## Tech Stack
- **Platform**: iOS 18.6+ (minimum supported version, home use only), with unused macOS/watchOS targets, Swift 6
- **UI**: SwiftUI (primary), UIKit (AR components)
- **Architecture**: Hybrid MVVM-MV pattern
- **Networking**: Apollo GraphQL client
- **AR**: ARKit, RealityKit, Vision Framework
- **Auth**: Apple Sign-In with Keychain storage
- **Backend**: tea-elephant.com GraphQL API
- **Additional**: NFC support, QR code scanning, AI-powered recommendations

## Project Structure
```
TeaElephant/
├── Shared/                     # Shared code across platforms
│   ├── ARBoxesView/           # AR visualization features
│   ├── TagManagement/         # NFC/QR tag handling
│   ├── UserArea/              # Main user features
│   │   ├── Auth/              # Authentication
│   │   └── Collections/       # Tea collection management
│   ├── Network.swift          # Apollo client setup
│   └── api/                   # GraphQL schema package
├── TeaElephant/               # iOS app target
├── TeaElephant-macOS/         # Unused macOS target
├── TeaElephantAppClip/        # Minimal App Clip
└── TeaElephantWatch/          # Unused watchOS target
```

## Current Refactoring Status

### High Priority Issues (In Progress)
1. ✅ **Naming inconsistencies** - Files like "collectionsMnagement.swift" need renaming
2. ⏳ **Error handling** - Needs comprehensive error handling implementation
3. ⏳ **State management** - Inconsistent use of singletons vs ObservableObject
4. ⏳ **Network abstraction** - Direct Apollo usage needs repository pattern

### Known Technical Debt
- No unit tests
- Tight coupling to GraphQL schema
- Mixed responsibilities in some ViewModels
- Unused platform targets (macOS, watchOS)
- Some potential memory leaks from retain cycles

## Key Features

### Tea Collection Management
- CRUD operations for tea collections
- GraphQL subscriptions for real-time updates
- AI-powered tea recommendations based on "feelings"
- QR code and NFC tag support for tea identification

### AR Visualization
- ARKit session management for placing virtual objects
- Vision framework for barcode detection in AR
- Custom 3D entity overlays for tea information
- Real-time tracking of multiple markers

### Authentication
- Apple Sign-In integration
- Secure token storage in Keychain
- Bearer token authentication with Apollo interceptors
- Device ID tracking for sessions

## Code Conventions

### File Naming
- Use PascalCase for Swift files (e.g., `CollectionsManagement.swift`)
- Group related files in feature folders
- Suffix ViewModels with `ViewModel`

### Architecture Patterns
- Use MVVM for all new features
- ViewModels should be `@MainActor` and conform to `ObservableObject`
- Prefer `@StateObject` for view-owned objects
- Use dependency injection over singletons where possible

### State Management
```swift
// Preferred pattern for ViewModels
@MainActor
final class SomeViewModel: ObservableObject {
    @Published private(set) var state: State
    private let service: ServiceProtocol
    
    init(service: ServiceProtocol) {
        self.service = service
    }
}
```

### Error Handling
All new code should use the standardized error handling:
```swift
enum AppError: LocalizedError {
    case networkError(String)
    case authenticationFailed
    case dataCorrupted
    case unknown(Error)
}
```

## GraphQL Operations
- Queries/Mutations are in `Shared/api/`
- Use Apollo's code generation for type safety
- Subscriptions for real-time features

## Testing Requirements
While no tests exist currently, new features should include:
- Unit tests for ViewModels (target 80% coverage)
- Unit tests for Services (target 90% coverage)
- Integration tests for critical flows

## Important Notes for AI Assistants

### DO:
- Maintain production-quality code architecture
- Follow MVVM pattern consistently
- Implement proper error handling
- Use dependency injection for new services
- Keep AR features isolated from main app logic
- Fix naming inconsistencies when found

### DON'T:
- Don't worry about iOS version compatibility (18+ is fine)
- Don't create environment configurations (hardcoded URLs are acceptable)
- Don't modify the GraphQL schema without coordination
- Don't use singletons for new services
- Don't add features to unused platform targets

### Current Refactoring Priorities
1. **Immediate**: Fix file naming, implement error handling
2. **Next**: Abstract network layer, standardize state management
3. **Future**: Add tests, remove unused targets, implement logging

## Build & Run Instructions
1. Open `TeaElephant.xcworkspace` in Xcode
2. Select TeaElephant target for iOS
3. Build and run on iOS 18+ device or simulator
4. Backend API at tea-elephant.com should be accessible

## Common Issues & Solutions

### AR Not Working
- Ensure device supports ARKit
- Check camera permissions
- AR features require physical device (not simulator)

### GraphQL Errors
- Check network connectivity to tea-elephant.com
- Verify authentication token in Keychain
- Check Apollo cache for stale data

### Build Errors
- Clean build folder (Cmd+Shift+K)
- Reset package caches if SPM issues
- Ensure Xcode 16+ with iOS 18.6 SDK

## Contact & Resources
- Backend API: tea-elephant.com/v2/query
- GraphQL Schema: Located in `Shared/api/schema`
- This is a home project, not for production distribution