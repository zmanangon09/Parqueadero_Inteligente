# Plan — Módulo 1: Autenticación

**Objetivo:** Firebase Auth (registro/login/logout) + perfil en Firestore, Clean Architecture, MVVM con Provider.

## Qué se realizará

- Dependencias: firebase, provider, go_router, dartz, get_it, google_fonts, mocktail
- Core: failures, validators, theme (Material 3 Trust Teal), DI (get_it), router (GoRouter)
- Domain: UserEntity, AuthRepository interface, 4 use cases (login, register, logout, getCurrentUser)
- Data: UserModel, AuthRemoteDataSource, UserRemoteDataSource, AuthRepositoryImpl
- Presentation: AuthViewModel (ChangeNotifier), LoginView, RegisterView, widgets base
- Tests: LoginUseCase (×3) + AuthViewModel (×4) con mocktail
