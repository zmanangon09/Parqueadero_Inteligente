# Módulo 6 — Check-in / Check-out (QR)

## 1. Entidades involucradas
- `ReservaEntity` (existente): usa `qrCode`, `limiteCheckIn`, `checkInRealizado`, `estado`.
- No se crean entidades nuevas.

## 2. Casos de uso
- `ProcesarQrUseCase`: decide la acción según el estado de la reserva escaneada:
  - `activa` sin check-in y dentro de la ventana → **check-in**.
  - `activa` sin check-in y fuera de la ventana → **no-show** (cancela y libera).
  - `activa` con check-in → **check-out** (completa y libera espacio).
  - `pendiente` → rechazado (falta pago); `completada/cancelada` → rechazado.
- `LiberarReservasExpiradasUseCase`: barrido de no-shows (reservas `pendiente|activa` sin check-in con `limiteCheckIn` vencido → `cancelada` + espacio `libre`). Se ejecuta al abrir el dashboard admin y el historial del cliente.

## 3. Repositories
- `ReservaRepository` (ampliado): `getReservaByQr`, `checkIn`, `checkOut`, `liberarReservasExpiradas`.

## 4. Datasources
- `ReservaRemoteDatasource` (ampliado): las mismas operaciones sobre Firestore. `checkOut` y el barrido usan transacción/batch e incrementan `espaciosDisponibles`. El QR es el **id del documento** de la reserva (se escribe en `qrCode` al crearla).

## 5. ViewModel
- `QrScanViewModel`: procesa el QR detectado y expone el resultado (check-in / check-out / no-show / error).

## 6. Estructura de archivos
- `lib/domain/usecases/reservas/procesar_qr_usecase.dart`
- `lib/domain/usecases/reservas/liberar_reservas_expiradas_usecase.dart`
- `lib/presentation/viewmodels/qr_scan_viewmodel.dart`
- `lib/presentation/views/admin/qr_scan_view.dart` (ruta `/admin/scan_qr`, cámara con `mobile_scanner`)
- `lib/presentation/widgets/qr_reserva_dialog.dart` (cliente: muestra su QR con `qr_flutter`)

## 7. Dependencias
- `mobile_scanner` (escaneo, stack obligatorio), `qr_flutter` (render del QR).
