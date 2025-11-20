# Repository Guidelines

## Project Structure & Module Organization
- App sources live in `Aussie Porfolio/Aussie Porfolio/`, organized by feature: `Models/` (Realm objects), `ViewModels/` (MVVM logic), `Views/` (UIKit controllers & views), `Coordinators/` (navigation), `Services/` (data, e.g., `RealmService`), `Extensions/`, `Utils/`, `LaunchScreen/`, and assets in `Assets.xcassets`.
- Tests sit beside the app under `Aussie Porfolio/Aussie PorfolioTests` and UI specs in `Aussie Porfolio/Aussie PorfolioUITests`.
- Project files live in `Aussie Porfolio/Aussie Porfolio.xcodeproj`; the SPM manifest (`Package.swift`) lists Realm.

## Build, Run, and Development Commands
- Open the workspace for local dev: `open "Aussie Porfolio/Aussie Porfolio.xcodeproj"` (select the `Aussie Porfolio` scheme).
- Resolve dependencies (Realm via SPM) if Xcode prompts: File → Add Package → `https://github.com/realm/realm-swift.git` (>=10.45.0).
- CLI build: `xcodebuild -scheme "Aussie Porfolio" -destination 'platform=iOS Simulator,name=iPhone 15' build`.
- CLI tests: `xcodebuild test -scheme "Aussie Porfolio" -destination 'platform=iOS Simulator,name=iPhone 15'`.
- Keep `Pods/` untouched unless you explicitly update CocoaPods; prefer SPM for Realm.

## Coding Style & Naming Conventions
- Swift 5, UIKit, MVVM + Coordinators; prefer dependency injection and keep navigation logic inside coordinators.
- Indentation: 4 spaces; favor `final` classes when not subclassed; mark properties `private`/`internal` deliberately.
- Naming: view controllers end with `ViewController`, view models with `ViewModel`, coordinators with `Coordinator`, Realm models are singular nouns in `Models/`.
- Group related helpers under `Extensions/` or `Utils/`; keep storyboard-free flow (UI built in code).

## Testing Guidelines
- Unit tests use the new `Testing` framework (`@Test` + `#expect`) in `Aussie PorfolioTests`.
- Give test files the `Tests.swift` suffix and mirror the module path (e.g., `ViewModels/DashboardViewModelTests.swift`).
- Add fast, deterministic tests for new business logic; mock Realm where possible to avoid on-disk state.
- Run `xcodebuild test -scheme "Aussie Porfolio" -destination 'platform=iOS Simulator,name=iPhone 15'` before submitting.

## Commit & Pull Request Guidelines
- Follow the existing short, action-first commit style (e.g., "add launch page", "add insurance"). One focused change per commit.
- PRs: include a concise summary, screenshots for UI changes, linked issue/trello ticket, and the test command/output you ran. Call out new dependencies or migrations explicitly.
- Keep branches up to date with `main` and resolve merge warnings before requesting review.

## Security & Configuration Notes
- Do not commit secrets or personal data; sample data belongs in fixtures/tests only.
- If Realm schema changes, document migration steps in the PR description and update any seed/setup instructions in `README.md`.
