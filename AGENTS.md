# Repository Guidelines

## Project Structure & Module Organization
- App code lives in `Aussie Porfolio/Aussie Porfolio/` grouped by feature: `DashboardTab/`, `PropertiesTab/`, `CashFlowTab/`, `CashAccountsTab/`, `LiabilitiesTab/`, `AssetsTab/`, plus shared `Models/`, `Services/` (RealmService, coordinators), `Extensions/`, `Utils/`, `Assets.xcassets/`, and `LaunchScreen/`.
- Each tab folder keeps its view controllers, view models, and local views together; legacy shared views remain under `Views/`.
- Tests sit in `Aussie Porfolio/Aussie PorfolioTests` and UI automation in `Aussie Porfolio/Aussie PorfolioUITests`.
- Project file: `Aussie Porfolio/Aussie Porfolio.xcodeproj`; Realm is declared in `Package.swift` (SPM). Ensure newly added files are part of the app target after moving.

## Build, Test, and Development Commands
- Open the project: `open "Aussie Porfolio/Aussie Porfolio.xcodeproj"` and pick the `Aussie Porfolio` scheme (iOS 16+ deployment).
- CLI build: `xcodebuild -scheme "Aussie Porfolio" -destination 'platform=iOS Simulator,name=iPhone 15' build`.
- CLI tests: `xcodebuild test -scheme "Aussie Porfolio" -destination 'platform=iOS Simulator,name=iPhone 15'`.
- If Realm is missing, add the SPM package `https://github.com/realm/realm-swift.git` (>=10.45.0). Keep `Pods/` untouched unless you consciously manage CocoaPods.

## Coding Style & Naming Conventions
- Swift 5, UIKit + MVVM with Coordinators; prefer dependency injection and keep navigation in coordinators.
- Indentation: 4 spaces; mark types `final` when appropriate; default to `private`/`fileprivate` for impl details.
- Naming: `...ViewController`, `...ViewModel`, `...Coordinator`; Realm models are singular nouns in `Models/`. Use clear currency helpers for money display.
- Avoid duplicating feature types—place Cash Flow pieces in `CashFlowTab/`, Properties in `PropertiesTab/`, etc.

## Testing Guidelines
- Unit tests use the `Testing` framework (`@Test`, `#expect`). Mirror module paths, e.g., `CashFlowTab/CashFlowViewModelTests.swift`.
- Favor deterministic tests by mocking Realm or using in-memory configs. Add coverage when changing cashflow math or migrations.
- Run `xcodebuild test ...` before opening PRs; include the exact command/output.

## Commit & Pull Request Guidelines
- Commit messages are short and action-first (e.g., `add rental income section`, `fix cashflow stats`). Keep commits focused per concern.
- PR checklist: summary, screenshots for UI changes, linked issue/ticket, noted migrations (Realm schema v7 currently), and test results. Call out new dependencies or config steps.

## Data & Migration Notes
- Realm schema v7 adds loan/rental/expense fields; bump schema and provide migration blocks when altering models.
- Never commit real secrets or personal data; seed/demo data belongs only in fixtures or local dev helpers.
