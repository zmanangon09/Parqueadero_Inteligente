# Ejecución — Módulo 1: Autenticación

**Estado:** Completado ✓  
**Fecha:** 2026-06-30

## Archivos creados

### Core
- `lib/core/errors/failures.dart` — Failure, ServerFailure, AuthFailure, ValidationFailure
- `lib/core/utils/validators.dart` — email(), password(), required(), phone()
- `lib/core/theme/app_theme.dart` — Material 3, paleta Trust Teal (#0F766E), Outfit/Work Sans
- `lib/core/di/injection.dart` — get_it: registra datasources, repos, use cases, AuthViewModel
- `lib/core/router/app_router.dart` — GoRouter con refreshListenable + redirect por sesión

### Domain
- `lib/domain/entities/user_entity.dart` — UserEntity + enum UserRole {admin, cliente}
- `lib/domain/repositories/auth_repository.dart` — interface AuthRepository
- `lib/domain/usecases/auth/login_usecase.dart`
- `lib/domain/usecases/auth/register_user_usecase.dart`
- `lib/domain/usecases/auth/logout_usecase.dart`
- `lib/domain/usecases/auth/get_current_user_usecase.dart`

### Data
- `lib/data/models/user_model.dart` — fromFirestore(), toFirestore(), fromFirebaseUser()
- `lib/data/datasources/remote/auth_remote_datasource.dart` — wraps FirebaseAuth
- `lib/data/datasources/remote/user_remote_datasource.dart` — wraps Firestore `usuarios/{uid}`
- `lib/data/repositories/auth_repository_impl.dart` — mapea FirebaseAuthException → AuthFailure en español

### Presentation
- `lib/presentation/viewmodels/auth_viewmodel.dart` — ChangeNotifier, enum AuthStatus
- `lib/presentation/views/auth/login_view.dart`
- `lib/presentation/views/auth/register_view.dart`
- `lib/presentation/widgets/custom_text_field.dart`
- `lib/presentation/widgets/primary_button.dart`
- `lib/presentation/widgets/auth_header.dart`
- `lib/main.dart` — Firebase.initializeApp + ChangeNotifierProvider + MaterialApp.router

### Firebase
- `lib/firebase_options.dart` — generado por FlutterFire CLI, proyecto `smart-parking-mrcc`

## Tests
- `test/domain/usecases/auth/login_usecase_test.dart` — 3 tests ✓
- `test/presentation/viewmodels/auth_viewmodel_test.dart` — 4 tests ✓
- **Total: 7/7 tests en verde**

## Notas
- SDK constraint bajado a `^3.11.4` (Dart instalado es 3.11.4)
- `firebase_options.dart` generado con `flutterfire configure` (proyecto: smart-parking-mrcc)
- Pendiente en Firebase Console: activar Email/Password Auth, crear Firestore DB, activar Storage
