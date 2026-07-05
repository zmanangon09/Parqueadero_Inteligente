# Ejecución — Módulo 8: Perfil

## Qué hace
- `/perfil` (icono de persona en la barra del Home): avatar (foto o inicial), correo, teléfono, fecha de registro.
- **Vehículos**: chips de placas con eliminar; "Agregar" abre diálogo con validación de placa. Las placas alimentan el dropdown del sheet de reserva (que ya tenía soporte).
- **Foto de perfil**: tocar el ícono de cámara → galería → sube a Storage `perfiles/{uid}.jpg` → guarda `fotoUrl` en `usuarios/{uid}`.
- Tras cada cambio se llama `AuthViewModel.updateCurrentUser(...)` (método nuevo) para refrescar la sesión en memoria sin tocar `status` (evita rebotes del redirect de go_router).

## Archivos
- Creados: `storage_remote_datasource.dart`, `update_vehiculos_usecase.dart`, `update_foto_perfil_usecase.dart`, `perfil_viewmodel.dart`, `views/perfil/perfil_view.dart`.
- Modificados: `user_entity.dart` + `user_model.dart` (+`fotoUrl`), `user_remote_datasource.dart`, `auth_repository(.dart|_impl.dart)` (ahora recibe `StorageRemoteDatasource`), `auth_viewmodel.dart` (+`updateCurrentUser`), `app_router.dart`, `injection.dart`, `Info.plist` (`NSPhotoLibraryUsageDescription`).

## Nota
- Si el bucket de Storage no existe en el proyecto Firebase, la subida falla con snackbar de error; crear el bucket default en Firebase Console → Storage.
