# Expense Tracker

A modern, production-ready expense tracking app built with Flutter.

## Stack

- **Flutter** 3.22+ / **Dart** 3.4+
- **Riverpod 2** — state management
- **Hive** — local storage (typed boxes, no codegen)
- **go_router** — declarative routing with shell route for bottom nav
- **fl_chart** — charts and graphs
- **Material 3** — modern theming with light/dark mode
- **flutter_local_notifications** / **local_auth** / **image_picker** — platform integrations

## Architecture

Clean Architecture per feature:

```
lib/
├── core/                       # Cross-cutting concerns
│   ├── constants/              # App + Hive box names
│   ├── errors/                 # Failures, exceptions
│   ├── router/                 # go_router config
│   ├── theme/                  # Colors, typography, ThemeData
│   └── utils/                  # Formatters, date helpers, extensions
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/                   # PIN + biometric
│   ├── dashboard/
│   ├── transactions/
│   ├── categories/
│   ├── budget/
│   ├── analytics/
│   └── settings/
│       Each feature has:
│         data/         (models with Hive adapters, datasources, repository impls)
│         domain/       (entities, repository interfaces)
│         presentation/ (providers, screens, widgets)
├── services/                   # Notifications, biometric, export, backup (stubs)
├── shared/widgets/             # Reusable UI components
├── app.dart
└── main.dart
```

## Why Riverpod (over Bloc / Provider)

- Compile-time safety, no `BuildContext` needed inside notifiers
- Trivial dependency injection (`ref.watch`/`ref.read`)
- Auto-disposal of state when unused → no manual lifecycle management
- Far less boilerplate per feature than Bloc, with stronger guarantees than Provider

## Why Hive (over SQLite)

- This domain is mostly entity reads/writes (transactions, categories, budgets) — no joins
- Zero-config typed object storage with hand-written `TypeAdapter`s
- Faster reads than sqflite for our usage pattern
- Repository pattern keeps the option open to swap to SQLite/Drift later

## Getting Started

1. Install Flutter (stable channel, 3.22+): https://docs.flutter.dev/get-started/install
2. From this directory:
   ```bash
   flutter pub get
   flutter run
   ```
3. (Optional, first run only) If platform folders need refresh:
   ```bash
   flutter create . --platforms=android --org com.example --project-name expense_tracker
   ```
   This fills in Gradle wrapper / generated files without overwriting our source.

## Feature Status (MVP scaffold)

| Module           | Status                                                   |
|------------------|----------------------------------------------------------|
| Splash           | Working                                                  |
| Onboarding       | Working                                                  |
| PIN auth         | Working                                                  |
| Biometric        | Service stub — wire `local_auth` in `BiometricService`   |
| Dashboard        | Working with live data + charts                          |
| Transactions     | Full CRUD + filter + search                              |
| Categories       | Full CRUD with icon + color                              |
| Budgets          | Full CRUD + usage tracking                               |
| Analytics        | Working with pie + bar + trend charts                    |
| Notifications    | Service stub — wire `flutter_local_notifications`        |
| CSV/PDF export   | Service stub                                             |
| Backup/restore   | Service stub                                             |
| Settings         | Theme, currency, app lock all working                    |

Stubbed services expose the production API surface; implementations are short and isolated to the corresponding `services/*.dart` file. See the `TODO(prod)` markers.

## Extending

- Add a feature: create `lib/features/<name>/{data,domain,presentation}` and register a route in `core/router/app_router.dart`.
- Add a Hive entity: define a class with a `TypeAdapter`, register in `main.dart`, open a box, add a repository.
- Wire REST backend: implement a new `*_remote_datasource.dart` and switch the repository impl to read remote-first with local cache.
