# Módulo 8 — Perfil

## 1. Entidades involucradas
- `UserEntity` (ampliada): + `fotoUrl` (nullable). `vehiculos` ya existía.

## 2. Casos de uso
- `UpdateVehiculosUseCase`: valida placas (`Validators.placa`), normaliza (mayúsculas, sin duplicados) y persiste.
- `UpdateFotoPerfilUseCase`: sube imagen a Firebase Storage (`perfiles/{uid}.jpg`) y guarda la URL.

## 3. Repositories
- `AuthRepository` (ampliado): `updateVehiculos`, `updateFotoPerfil` — ambos devuelven el usuario actualizado.

## 4. Datasources
- `UserRemoteDataSource` (ampliado): `updateVehiculos`, `updateFotoUrl`.
- `StorageRemoteDatasource` (nuevo): `uploadFotoPerfil` con Firebase Storage.

## 5. ViewModel
- `PerfilViewModel`: agregar/eliminar placa, cambiar foto; expone `updatedUser` para refrescar el `AuthViewModel` sin `checkSession` (que dispararía el redirect del router).

## 6. Estructura de archivos
- `lib/data/datasources/remote/storage_remote_datasource.dart`
- `lib/domain/usecases/perfil/update_vehiculos_usecase.dart`
- `lib/domain/usecases/perfil/update_foto_perfil_usecase.dart`
- `lib/presentation/viewmodels/perfil_viewmodel.dart`
- `lib/presentation/views/perfil/perfil_view.dart` (ruta `/perfil`)

## 7. Dependencias
- Ninguna nueva (`firebase_storage` e `image_picker` ya estaban).
