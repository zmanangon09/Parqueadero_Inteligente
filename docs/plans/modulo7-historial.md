# Módulo 7 — Historial de reservas

## 1. Entidades involucradas
- `ReservaEntity` (existente). Sin entidades nuevas.

## 2. Casos de uso
- `GetReservasUsuarioUseCase`: reservas del usuario, orden descendente por fecha.
- Reusa `LiberarReservasExpiradasUseCase` (barrido antes de mostrar) y `CancelarReservaUseCase` (cancelar una pendiente desde el historial).

## 3. Repositories
- `ReservaRepository` (ampliado): `getReservasByUsuario`.

## 4. Datasources
- `ReservaRemoteDatasource` (ampliado): `getReservasByUsuario` con `where usuarioId ==` y orden client-side (sin índice compuesto).

## 5. ViewModel
- `HistorialViewModel`: secciones **Activas** (pendiente + activa) y **Pasadas** (completada + cancelada); mapea nombres de parqueaderos.

## 6. Estructura de archivos
- `lib/domain/usecases/reservas/get_reservas_usuario_usecase.dart`
- `lib/presentation/viewmodels/historial_viewmodel.dart`
- `lib/presentation/views/historial/historial_view.dart` (ruta `/historial`, acceso desde la barra superior del Home)

## 7. Dependencias
- Ninguna nueva.
