# Repository Guidelines

## Project Structure & Module Organization
- `TeaElephant/`: App entry and app-specific SwiftUI views and assets.
- `Shared/`: Cross-platform features (e.g., `UserArea/`, `TagManagement/`, `Core/`, `Views/`, `api/`). GraphQL operations live in `Shared/api`, generated types in `Shared/api/schema`.
- `TeaElephantAppClip/`: App Clip target sources.
- `TeaElephantTests/` and `TeaElephantUITests/`: XCTest unit and UI tests.
- `docs/`: Design and agent docs (see `docs/CLAUDE.md`, `docs/GEMINI.md`).

## Build, Test, and Development Commands
- Build (CLI): `xcodebuild -workspace TeaElephant.xcworkspace -scheme TeaElephant build`
- Run tests (CLI): `xcodebuild test -workspace TeaElephant.xcworkspace -scheme TeaElephant -destination 'platform=iOS Simulator,name=iPhone 15'`
- Open in Xcode: `open TeaElephant.xcworkspace`
- GraphQL schema/codegen (Apollo):
  - Download schema: `./apollo-ios-cli download-schema --config Shared/api/apollo-codegen-config.json`
  - Generate types: `./apollo-ios-cli generate --config Shared/api/apollo-codegen-config.json`

## Coding Style & Naming Conventions
- Swift 5, Xcode formatting, 4-space indentation; follow Swift API Design Guidelines.
- Types: UpperCamelCase; methods/vars/cases: lowerCamelCase; files named after primary type.
- Group code by feature folder (e.g., `UserArea`, `Search`, `TagManagement`). Avoid force-unwraps; prefer dependency injection (`Shared/Core/DependencyInjection`).

## Testing Guidelines
- Framework: XCTest. Name files `*Tests.swift`; test methods start with `test`.
- Run locally via Xcode or the CLI command above. Aim to cover new/changed logic, especially repositories and interceptors.
- Prefer unit tests for `Core/*` and pure views; add UI tests for key flows. Mock network/Apollo where feasible.

## Commit & Pull Request Guidelines
- Use concise, imperative subjects. Prefer Conventional Commits (`feat:`, `fix:`, `chore:`) as seen in history.
- PRs include: clear description, linked issues, screenshots for UI changes, and notes on testing.
- Keep changes scoped; update docs under `docs/` when relevant.

## Security & Configuration Tips
- Do not commit secrets or tokens. Auth lives in `Shared/UserArea/Auth/*` — use secure storage.
- Apollo endpoints are configured in `Shared/api/apollo-codegen-config.json`; avoid hardcoding URLs in code.
- Respect `.gitignore`; avoid committing derived data or local build artifacts.
