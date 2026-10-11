# TeaElephant for iOS

TeaElephant connects a personal drink collection to the labels on its boxes.
Scan an NFC tag or QR code to read a tea's details, attach brewing temperature
and a best-before date to a label, organise labelled drinks into collections,
and ask the backend for a recommendation from your collection.

The app is written in Swift and SwiftUI. It uses Core NFC for tags,
Vision/RealityKit for camera and AR flows, and Apollo for the GraphQL API.

## What the app does

- **Read drink information:** scan an NFC tag or an existing QR label to show
  the linked catalogue entry and its package-specific metadata.
- **Label a drink:** select an existing catalogue entry or enter its details,
  set the best-before date and brewing temperature, then write an NFC tag or
  associate an existing QR code with the record. Creating a new catalogue entry
  also requires permission from the backend.
- **Manage collections:** sign in with Apple, create named collections, scan
  QR-labelled records into them, and remove records you no longer need.
- **Choose what to drink:** request a streaming recommendation using the
  collection and a description of how you feel. The home screen also includes
  a Tea of the Day card backed by the server.
- **Explore with the camera:** detect QR-labelled boxes and display their
  information in the AR viewer on a supported device.
- **Use optional wellness context:** with HealthKit permission, generate an
  editable description of your current state for the recommendation form.
- **Open notification destinations:** the app registers a device for backend
  notifications and opens the linked record when a notification is selected.

The repository also contains an App Clip target. It shares application code,
uses `APPCLIP` branches for restricted flows, and offers the full app where
needed. The main app archive includes the App Clip.

## Part of the TeaElephant product

| Repository | Responsibility |
| --- | --- |
| [teaElephant](https://github.com/teaelephant/teaElephant) | iOS app, NFC/QR interactions, personal collections and recommendations |
| [Editor](https://github.com/teaelephant/Editor) | macOS administrative editor for the shared drink catalogue and tags |
| [TeaElephantMemory](https://github.com/teaelephant/TeaElephantMemory) | Go GraphQL backend, PostgreSQL storage, authentication, AI and notifications |

Catalogue information and label metadata are different records. A catalogue
entry holds the drink's name, type and description. Label metadata identifies
the entry and adds a brewing temperature and best-before date for that package.
NFC stores metadata on the tag; QR labels identify records held by the backend.
Collections contain those QR records.

## Requirements

- A Mac with Xcode and its command-line tools selected. Use an Xcode release
  whose SDK supports the project's **iOS 26.6** deployment target; the current
  development toolchain is Xcode 27.
- A **Swift 6.1 or newer compiler** for the generated schema package. The app
  uses Swift 6 language mode.
- An installed iOS Simulator runtime for builds and automated tests.
- A compatible iPhone for NFC, camera scanning and AR checks. These hardware
  paths cannot be fully validated in Simulator.
- A reachable TeaElephant backend for catalogue reads, QR records, collections
  and recommendations. Apple sign-in and notifications also need the matching
  server and Apple configuration.

Packages are managed by Swift Package Manager; no CocoaPods installation is
needed. The committed workspace lockfile currently resolves:

| Package | Version | Use |
| --- | --- | --- |
| Apollo iOS | 2.4.0 | Typed GraphQL operations, cache and WebSocket transport |
| CodeScanner | 2.5.2 | QR scanning |
| KeychainSwift | 24.0.0 | User session token storage |
| MessagePacker | 0.4.7 | NFC metadata encoding |

See [dependency maintenance](docs/DEPENDENCIES.md) before updating packages or
the matching Apollo CLI.

## Build and run

```sh
git clone https://github.com/teaelephant/teaElephant.git
cd teaElephant
open TeaElephant.xcworkspace
```

In Xcode, select the `TeaElephant` scheme, choose an installed iPhone simulator,
and run. Xcode resolves the committed package dependencies. For a command-line
build, first list the available simulator devices:

```sh
xcrun simctl list devices available
xcodebuild -workspace TeaElephant.xcworkspace -scheme TeaElephant \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath .build/DerivedData build
```

Replace `iPhone 18 Pro` with a device installed on your Mac. To run on a physical
iPhone, select a development team and provisioning profiles for both the app
and App Clip. Their identifiers, capabilities and parent/child relationship
must agree with the Apple configuration and backend.

The app bundle identifier is `xax.TeaElephant`. Device builds use the declared
Sign in with Apple, associated-domain, NFC, push notification and HealthKit
capabilities; Simulator builds do not demonstrate that these services work.

## Backend and authentication

The runtime transport is configured in
[Network.swift](Shared/Core/Network/Network.swift):

| Connection | Default endpoint |
| --- | --- |
| GraphQL queries and mutations | `https://tea-elephant.com/v2/query` |
| GraphQL subscriptions | `wss://tea-elephant.com/v2/query` |
| Schema introspection for code generation | `http://localhost:8080/v2/query` |

The introspection URL belongs to the
[Apollo codegen configuration](Shared/api/apollo-codegen-config.json).
Changing it does **not** change the app's runtime server. To use another server,
update both runtime transport URLs and keep them pointed at the same backend.
Use the [backend setup guide](https://github.com/teaelephant/TeaElephantMemory#local-setup-with-docker-compose)
to run the API locally.

Public catalogue reads do not establish a user session. Apple sign-in exchanges
an authorization code with the backend; the returned token is stored in
Keychain and used for HTTP requests and WebSocket `connection_init`. Personal
collections and recommendations require a user session. Administrative
catalogue writes use the separate authorization configured in Editor.

The mobile app does not need an OpenAI API key. AI requests go through the
backend, which owns provider credentials and model selection.

HealthKit samples are read and summarised on the device. If the user submits a
recommendation after auto-fill, the resulting **feelings text is sent to the
backend** along with the recommendation request. Keep this distinction when
changing privacy text or adding new health inputs.

## Architecture and source map

The entry point is `TeaElephantApp`; onboarding leads to `ContentView` and
`Menu`. SwiftUI views use observable managers. `Shared/Core` also contains
repository protocols, implementations and a dependency container; older flows
still call `Network.shared` directly.

Apollo splits HTTP queries/mutations from WebSocket subscriptions. Its
normalised cache is held in memory. Cancellation and UI delivery are handled by
the async adapters in `Shared/ApolloClientExtension.swift`.

| Path | Contents |
| --- | --- |
| `TeaElephant/` | Main app entry point, onboarding, assets, Info.plist and entitlements |
| `Shared/Views/` | Home, reading and writing forms, drink cards and Tea of the Day |
| `Shared/TagManagement/`, `Shared/QRManagement/` | NFC sessions, metadata encoding and QR record lookup/writes |
| `Shared/UserArea/` | Apple sign-in, collections and streaming recommendation screens |
| `Shared/ARBoxesView/` | Camera detection and AR presentation |
| `Shared/Core/` | Network abstraction, repositories, dependency injection and wellness helpers |
| `Shared/api/` | GraphQL operations, codegen configuration and committed schema snapshot |
| `Shared/api/schema/` | Generated `TeaElephantSchema` Swift package |
| `TeaElephantAppClip/` | App Clip entry point, full-app offer, assets and entitlements |
| `TeaElephantTests/`, `TeaElephantUITests/` | Unit/regression tests and UI tests |
| `ci/` | Export options for device and TestFlight distribution |

Several older or alternative view implementations remain in `Shared/Views`.
Follow the active navigation from `Menu` when changing a user flow rather than
assuming every similarly named view is used.

## Tests

Use the dedicated test schemes:

```sh
xcodebuild -workspace TeaElephant.xcworkspace -scheme TeaElephantTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
xcodebuild -workspace TeaElephant.xcworkspace -scheme TeaElephantUITests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

The unit suite covers authentication state, Apollo interception, QR lookup and
date parsing, NFC payloads/session behaviour, and catalogue selection during
saving. UI tests cover launching and form validation. Mocked transport and NFC
session tests exercise logic without contacting AI services or writing a tag.
Keep a separate device smoke check for scanning, NFC writing, AR, Apple sign-in,
HealthKit permissions and notifications.

## GraphQL code generation

After changing an operation, regenerate from the committed schema:

```sh
./apollo-ios-cli generate --path Shared/api/apollo-codegen-config.json
git diff -- Shared/api/schema
```

The wrapper downloads the pinned Apollo CLI, verifies its SHA-256 and caches it
under `.build/apollo-cli/2.4.0`. Add `--fetch-schema` only for an intentional
schema refresh with the configured local backend running. Commit operation
changes and their generated Swift files together, then run the unit suite.

## TestFlight

Archive the `TeaElephant` scheme for `generic/platform=iOS`, including its App
Clip, and export with [ci/testflight-exportoptions.plist](ci/testflight-exportoptions.plist).
The upload uses automatic signing and Xcode-managed build numbers. It requires
an Apple developer account with access to the app's App Store Connect record.
An accepted upload must finish Apple's processing before the build is usable.
The full commands are in [dependency maintenance](docs/DEPENDENCIES.md#testflight-delivery).

## Documentation and contributions

Start with the [documentation index](docs/README.md). It separates maintenance
instructions from feature designs and historical reviews.

Keep changes scoped to the affected flow, add regression coverage for changed
logic, and use concise commits such as `fix:` or `docs:`. A pull request should
describe the resulting behaviour, validation and any device-only checks still
needed. Keep tokens, Apple keys, signing material and local configuration out of
version control.
