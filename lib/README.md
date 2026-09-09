# SmartPath — Auth Feature (Presentation Layer)

Bloc-based presentation layer for the Login and Create Account screens, built
against a clean-architecture-style folder layout.

## Structure

```
lib/features/auth/
├── domain/
│   └── repositories/
│       └── auth_repository.dart      # abstract contract the cubits depend on
└── presentation/
    ├── cubit/
    │   ├── login_cubit.dart / login_state.dart
    │   └── register_cubit.dart / register_state.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── utils/
    │   └── password_strength.dart    # strength scoring for the register form
    └── widgets/
        ├── auth_gradient_header.dart # shared green header (back btn, title, subtitle)
        ├── auth_text_field.dart
        ├── password_field.dart       # + visibility toggle + strength meter
        ├── primary_auth_button.dart
        ├── sso_button.dart
        └── step_progress_bar.dart
```

## Install dependencies

```bash
flutter pub add flutter_bloc equatable
```

## Wire it up

The cubits take an `AuthRepository` via constructor injection — they don't
know about Firebase or any other backend. Provide a concrete implementation
above `MaterialApp`:

```dart
void main() {
  runApp(
    RepositoryProvider<AuthRepository>(
      create: (_) => FirebaseAuthRepository(), // your data-layer implementation
      child: const MyApp(),
    ),
  );
}
```

Then route to `LoginPage()` / `RegisterPage()` as normal — each page creates
its own `BlocProvider` internally, so no extra wiring is needed per-route.

## Design decisions worth knowing about

- **State shape**: each cubit exposes one `Equatable` state object (status +
  field values + field-level errors) rather than a stream of one-off event
  states. This keeps form data intact across rebuilds and makes
  `BlocConsumer`'s `listenWhen`/`builder` split trivial — errors are just
  fields, not a state you can "miss" if a rebuild is skipped.
- **Nullable `copyWith`**: a private `_unset` sentinel lets `copyWith` tell
  "leave this error alone" apart from "clear this error to null" — the usual
  gap in a naive `field: field ?? this.field` copyWith.
- **Controllers, not value-driven fields**: `AuthTextField`/`PasswordField`
  take a `TextEditingController` instead of reading `state.studentId`
  directly into `TextField(controller: ...)` on every build. Feeding a bloc
  value back into the controller on every rebuild is a classic cause of
  cursor-jump bugs on Android.
- **Student ID vs. Firebase Auth**: the login screen only collects a student
  ID, but Firebase Auth signs in with email/password. `AuthRepository.login`
  is written to take a `studentId` on purpose — see the doc comment on the
  interface for the two implementation options (Firestore lookup vs.
  synthetic email at registration).
- **Validation**: each cubit validates per-field on change and again on
  submit (defensive — covers the case where a field was never touched).
  Submit buttons are disabled via `state.isValid` rather than relying on a
  `Form`/`GlobalKey<FormState>`, since validity is already tracked in state.

## Not included (by design)

This is the presentation layer only. You'll still need:
- The data-layer `FirebaseAuthRepository implements AuthRepository`
- Named routes for `/login`, `/register`, `/home`, forgot-password
- The actual college/major list (currently a static placeholder)
