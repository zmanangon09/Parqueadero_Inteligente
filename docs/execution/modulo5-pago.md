# Ejecución — Módulo 5: Pago (simulado, estilo Stripe test-mode)

**Estado:** Completado ✓ (pendiente prueba manual end-to-end en dispositivo)
**Fecha:** 2026-07-03

## Flujo implementado

1. En el detalle del parqueadero, el usuario toca un espacio `libre`, elige placa y duración y confirma la reserva.
2. La reserva se crea en estado **`pendiente`** (antes era `activa`) y el espacio queda retenido (`ocupado`).
3. La app navega a la pantalla de **Pago** (`/pago/:reservaId`), pasando la `ReservaEntity` por `extra` de GoRouter para mostrar el monto sin re-consultar Firestore.
4. El usuario ingresa una tarjeta de prueba:
   - `4242 4242 4242 4242` → **éxito**: se crea `pagos/{id}` con estado `exitoso` y, en la misma transacción, la reserva pasa a `activa`. Diálogo "¡Pago exitoso!" → vuelve a Home.
   - `4000 0000 0000 0002` (u otra con formato válido) → **declinada**: se registra `pagos/{id}` con estado `fallido`, la reserva sigue `pendiente` (se puede reintentar) y se muestra SnackBar de error.
   - Formato inválido (largo/expiración/CVC) → error de validación **antes** de procesar, sin escribir en `pagos/`.
5. Botón "Cancelar y liberar espacio": la reserva pasa a `cancelada` y el espacio vuelve a `libre` (transacción); regresa a Home.

## Archivos creados

### Domain
- `lib/domain/entities/pago_entity.dart` — `PagoEntity` + enum `EstadoPago { exitoso, fallido }`
- `lib/domain/repositories/pago_repository.dart` — interface `registrarPago`
- `lib/domain/usecases/pagos/procesar_pago_usecase.dart` — valida tarjeta, decide éxito/fallo por número (`4242…` = éxito), construye el pago y delega en el repo; en éxito devuelve `Right`, en declinada `Left(ValidationFailure)`
- `lib/domain/usecases/reservas/cancelar_reserva_usecase.dart` — cancela la reserva y libera el espacio

### Data
- `lib/data/models/pago_model.dart` — `fromEntity`/`fromFirestore`/`toFirestore`
- `lib/data/datasources/remote/pago_remote_datasource.dart` — transacción Firestore: crea el pago y, solo si es exitoso, actualiza `reservas/{id}.estado = activa`; si es fallido solo escribe en `pagos/`
- `lib/data/repositories/pago_repository_impl.dart` — mapea errores de infraestructura a `ServerFailure`

### Presentation
- `lib/presentation/viewmodels/pago_viewmodel.dart` — estados idle/procesando/exito/error
- `lib/presentation/views/pago/pago_view.dart` — formulario de tarjeta (número, MM/YY, CVC), resumen de monto, diálogo de éxito, SnackBar de error y botón cancelar

## Archivos actualizados
- `lib/core/utils/validators.dart` — agrega `numeroTarjeta`, `expiracionTarjeta`, `cvc`
- `lib/domain/usecases/reservas/crear_reserva_usecase.dart` — reserva inicia en `pendiente`
- `lib/domain/repositories/reserva_repository.dart` — agrega `cancelarReserva`
- `lib/data/repositories/reserva_repository_impl.dart` — impl de `cancelarReserva`
- `lib/data/datasources/remote/reserva_remote_datasource.dart` — transacción `cancelarReserva` (reserva → cancelada, espacio → libre)
- `lib/core/di/injection.dart` — registra datasource, repositorio, `ProcesarPagoUseCase`, `CancelarReservaUseCase` y `PagoViewModel`
- `lib/core/router/app_router.dart` — nueva ruta `/pago/:reservaId`
- `lib/presentation/widgets/reserva_sheet.dart` — `showReservaSheet` devuelve la `ReservaEntity` creada (antes `bool`)
- `lib/presentation/views/parking/parqueadero_detail_view.dart` — tras crear la reserva navega a `/pago/:reservaId`

## Decisiones
- **Pago simulado (mock)**, sin backend ni cuenta Stripe: la secret key nunca iría en el cliente. Simulación determinista por tarjeta de prueba (imita a Stripe test mode).
- **Flujo `pendiente → pago → activa`**: el espacio se retiene desde la reserva; el pago exitoso confirma. En declinada la reserva sigue `pendiente` (reintentable); "Cancelar" la pasa a `cancelada` y libera el espacio.
- **Colección `pagos/` aparte** (una por dominio); guarda también los intentos fallidos.
- **Fuera de alcance (YAGNI):** liberación automática por timeout de reservas no pagadas (territorio del Módulo 6 / no-show) e historial de pagos para el admin.

## Tests
- `test/core/utils/validators_tarjeta_test.dart` — 8 tests: número (16 díg. con/sin espacios, vacío, longitud), expiración (MM/YY futura, formato inválido, vencida), CVC (3 díg., inválido)
- `test/domain/usecases/pagos/procesar_pago_usecase_test.dart` — 4 tests: tarjeta de éxito → `Right`/`exitoso`; declinada → `ValidationFailure` + pago `fallido`; formato inválido → `ValidationFailure` sin tocar el repo; `monto` == `reserva.montoTotal` y `ultimos4`
- `test/domain/usecases/reservas/crear_reserva_usecase_test.dart` — actualizado: la reserva ahora inicia `pendiente`
- **Total acumulado: 30/30 tests en verde**
- `flutter analyze lib/ test/` → sin errores (2 `info` de `Radio` deprecado en admin + 1 `warning` preexistente `tLejano`, ajenos al módulo)

## Firestore
- Nueva colección `pagos/` con campos: `reservaId`, `usuarioId`, `monto`, `moneda`, `metodo`, `ultimos4`, `estado`, `transactionId`, `fecha`.
