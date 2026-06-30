# Módulo 1 — Autenticación · Diseño

**Proyecto:** Control Inteligente de Parqueaderos (Flutter)
**Fecha:** 2026-06-30
**Arquitectura:** Clean Architecture (Domain / Data / Presentation) + MVVM en Presentation.

---

## 1. Objetivo del módulo

Registro, inicio y cierre de sesión con Firebase Auth + creación/lectura del documento
`usuarios/{uid}` en Cloud Firestore. Determina el `rol` (`admin` | `cliente`) que gobierna
la navegación posterior (panel admin condicional). Es la base de todos los módulos siguientes.

---

## 2. Sistema de diseño visual (global)

- **Plataforma:** Flutter + Material 3 (`useMaterial3: true`). App móvil nativa.
- **Estilo:** Flat Design + tarjetas bento (radio 16–24px). WCAG AA/AAA.
- **Paleta (elegida por el usuario):**
  | Rol | Hex | ColorScheme |
  |-----|-----|-------------|
  | Primary | `#0F766E` | primary (teal confianza) |
  | Secondary | `#14B8A6` | secondary |
  | CTA | `#0369A1` | acción / tertiary (azul) |
  | Background | `#F0FDFA` | surface |
  | Text | `#134E4A` | onSurface |
- **Tipografía:** Outfit (títulos) + Work Sans (cuerpo) vía `google_fonts`.
- **Interacción:** touch target ≥48px, micro-interacciones 150–300ms, sin layout shift, sin emojis como iconos.
- Detalle completo en `design-system/control-inteligente-de-parqueaderos/MASTER.md`
  y override de pantalla en `pages/auth.md`.

---

## 3. Domain

### Entities
- `UserEntity { uid, nombre, email, rol (Enum UserRole {admin, cliente}), telefono, fechaRegistro (DateTime), vehiculos (List<String>) }`

### Repository interface
- `AuthRepository`
  - `Future<Either<Failure, UserEntity>> register({email, password, nombre, telefono})`
  - `Future<Either<Failure, UserEntity>> login({email, password})`
  - `Future<Either<Failure, Unit>> logout()`
  - `Future<Either<Failure, UserEntity?>> getCurrentUser()`
  - `Stream<UserEntity?> authStateChanges()`

### Use Cases (uno por archivo)
- `RegisterUserUseCase`
- `LoginUseCase`
- `LogoutUseCase`
- `GetCurrentUserUseCase`

Todos retornan `Either<Failure, T>` (paquete `dartz`).

---

## 4. Data

### Models
- `UserModel extends UserEntity` con `fromFirestore(DocumentSnapshot)` / `toFirestore()` y `fromFirebaseUser`.

### Datasources (remote)
- `AuthRemoteDataSource` → envuelve `FirebaseAuth`
  (`signUp`, `signIn`, `signOut`, `currentUser`, `authStateChanges`).
- `UserRemoteDataSource` → envuelve `Cloud Firestore`
  (`createUserDoc`, `getUserDoc` en `usuarios/{uid}`).

### Repository impl
- `AuthRepositoryImpl implements AuthRepository`
  - Orquesta ambos datasources.
  - Mapea `FirebaseAuthException` / errores Firestore → `AuthFailure` / `ServerFailure`.

---

## 5. Presentation (MVVM)

### ViewModel
- `AuthViewModel extends ChangeNotifier`
  - Estado: `AuthStatus { idle, loading, authenticated, error }`, `String? errorMessage`, `UserEntity? currentUser`.
  - Métodos: `register(...)`, `login(...)`, `logout()`, `checkSession()`.
  - **Regla:** solo invoca UseCases. Nunca toca Firebase ni APIs directamente.

### Views
- `LoginView` — email, password, botón "Iniciar sesión", link a registro, errores inline.
- `RegisterView` — nombre, email, teléfono, password, confirmación, validaciones.

### Widgets reutilizables
- `CustomTextField` (con validación + estado de error)
- `PrimaryButton` (estado loading, deshabilitado durante async)
- `AuthHeader` (logo + título)

### Validaciones (`core/utils/validators.dart`)
- Email con formato válido.
- Password ≥ 6 caracteres.
- Campos requeridos no vacíos.
- (Placa de vehículo se reutilizará en módulos posteriores.)

---

## 6. Errores (`core/errors/`)
- `abstract Failure { message }`
- `ServerFailure`, `AuthFailure`, `ValidationFailure`.
- Mapeo de códigos Firebase Auth (`user-not-found`, `wrong-password`, `email-already-in-use`, etc.) a mensajes en español dentro de `AuthRepositoryImpl`.

---

## 7. Inyección de dependencias (`core/di/injection.dart`)
- `get_it` registra: datasources → repositories → use cases.
- `AuthViewModel` se expone con `ChangeNotifierProvider` en `MultiProvider` (`main.dart`).

---

## 8. Navegación (`core/router/app_router.dart`)
- `GoRouter` con `redirect`:
  - Sin sesión → `/login`.
  - Con sesión → `/home`.
  - Rutas: `/login`, `/register`, `/home` (placeholder en este módulo).

---

## 9. Estructura de archivos a crear

```text
lib/
├── core/
│   ├── theme/app_theme.dart
│   ├── errors/failures.dart
│   ├── utils/validators.dart
│   ├── router/app_router.dart
│   └── di/injection.dart
├── domain/
│   ├── entities/user_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/auth/{register_user, login, logout, get_current_user}.dart
├── data/
│   ├── models/user_model.dart
│   ├── datasources/remote/{auth_remote_datasource, user_remote_datasource}.dart
│   └── repositories/auth_repository_impl.dart
├── presentation/
│   ├── viewmodels/auth_viewmodel.dart
│   ├── views/auth/{login_view, register_view}.dart
│   └── widgets/{custom_text_field, primary_button, auth_header}.dart
└── main.dart
```

---

## 10. Dependencias (`pubspec.yaml`)

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  provider: ^latest
  go_router: ^latest
  dartz: ^latest
  get_it: ^latest
  google_fonts: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^latest
```

> Firebase requiere `flutterfire configure` (genera `firebase_options.dart`). Claves/config fuera del repo según el doc.

---

## 11. Pruebas unitarias (obligatorias del doc para este módulo)

- **Login exitoso** → `LoginUseCase` con `AuthRepository` mockeado (mocktail) retorna `Right(UserEntity)`.
- **Error por credenciales inválidas** → retorna `Left(AuthFailure)` y `AuthViewModel` expone `errorMessage`.

---

## 12. Criterios de aceptación

- [ ] Registro crea cuenta en Firebase Auth y documento en `usuarios/{uid}`.
- [ ] Login válido navega a `/home`; inválido muestra error en español.
- [ ] Logout limpia sesión y redirige a `/login`.
- [ ] Auto-login al reabrir la app si hay sesión activa.
- [ ] Ningún ViewModel/Widget accede a Firebase directamente.
- [ ] Los 2 tests unitarios pasan.
- [ ] Tema teal + Outfit/Work Sans aplicado vía `ThemeData` (cero colores hardcodeados).
