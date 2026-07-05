# Ejecución — Módulo 6: Check-in / Check-out (QR)

## Decisiones
- **El QR es el id del documento de la reserva**: al crearla, la transacción escribe `qrCode = reservaRef.id`. Sin generación extra de tokens.
- **Quién escanea**: el administrador, desde el dashboard (`Check-in / Check-out` → `/admin/scan_qr`). El cliente muestra su QR desde el historial (botón "Ver QR") o desde el diálogo de pago exitoso ("Ver mi QR").
- **No-show**: al escanear un QR con ventana vencida se cancela en el acto. Además hay un barrido lazy (`LiberarReservasExpiradasUseCase`) al abrir el dashboard admin y el historial del cliente — sin Cloud Functions, suficiente para el alcance académico.
- **Contador `espaciosDisponibles`**: ahora se mantiene con `FieldValue.increment` en crear (-1), cancelar (+1), check-out (+1) y barrido (+n por parqueadero).

## Archivos creados
- `lib/domain/usecases/reservas/procesar_qr_usecase.dart` (+ `QrAccion`, `QrResultado`)
- `lib/domain/usecases/reservas/liberar_reservas_expiradas_usecase.dart`
- `lib/presentation/viewmodels/qr_scan_viewmodel.dart`
- `lib/presentation/views/admin/qr_scan_view.dart`
- `lib/presentation/widgets/qr_reserva_dialog.dart`
- `test/domain/usecases/reservas/procesar_qr_usecase_test.dart` (5 tests)

## Archivos modificados
- `reserva_remote_datasource.dart`: `getReservaByQr`, `checkIn`, `checkOut`, `liberarReservasExpiradas`, qrCode al crear, incrementos de disponibilidad.
- `reserva_repository(.dart|_impl.dart)`: métodos nuevos.
- `admin_dashboard_view.dart`: tarjeta "Check-in / Check-out"; `admin_dashboard_viewmodel.dart`: barrido de expiradas en `init()`.
- `pago_view.dart`: botón "Ver mi QR" en el diálogo de éxito.
- `app_router.dart` + `injection.dart`: ruta y registros.
- `AndroidManifest.xml`: permiso `CAMERA`. `Info.plist`: `NSCameraUsageDescription`.

## Verificación
- `flutter test`: check-in, no-show, check-out, pendiente rechazado, QR inválido.
