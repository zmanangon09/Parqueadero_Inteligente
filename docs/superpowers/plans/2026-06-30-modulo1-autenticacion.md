# Módulo 1 — Autenticación

**Goal:** Firebase Auth (registro/login/logout) + perfil en Firestore, Clean Architecture, MVVM con Provider.

## Tasks

- [x] Task 1: `pubspec.yaml` — agregar firebase, provider, go_router, dartz, get_it, google_fonts, mocktail
- [x] Task 2: `core/errors/failures.dart` + `core/utils/validators.dart`
- [x] Task 3: `core/theme/app_theme.dart` — Material 3, paleta Trust Teal (#0F766E), Outfit/Work Sans
- [x] Task 4: Domain — `UserEntity`, `AuthRepository` (interface), 4 use cases (login, register, logout, getCurrentUser)
- [x] Task 5: Tests — `login_usecase_test.dart` (3 tests con mocktail)
- [x] Task 6: Data — `UserModel`, `AuthRemoteDataSource`, `UserRemoteDataSource`
- [x] Task 7: Data — `AuthRepositoryImpl` (mapeo FirebaseAuthException → AuthFailure en español)
- [x] Task 8: Core — `injection.dart` (get_it) + `app_router.dart` (GoRouter con refreshListenable)
- [x] Task 9: `AuthViewModel` (ChangeNotifier, enum AuthStatus) + `auth_viewmodel_test.dart` (4 tests)
- [x] Task 10: Widgets — `CustomTextField`, `PrimaryButton`, `AuthHeader`
- [x] Task 11: Views — `LoginView`, `RegisterView`
- [x] Task 12: `main.dart` — Firebase.initializeApp + ChangeNotifierProvider + MaterialApp.router

## Verificación final
- `flutter test` → 7 tests en verde
- `dart analyze lib/` → No issues found!
- `flutter run` → Login → Registro → auto-login → Cerrar sesión
