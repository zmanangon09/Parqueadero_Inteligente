# Plan — Módulo 5: Pago (simulado, estilo Stripe test-mode)

**Objetivo:** Tras crear una reserva, el usuario confirma el pago del `montoTotal` en una pantalla tipo Stripe. Un pago exitoso pasa la reserva de `pendiente` a `activa`. Se crea el documento `pagos/{id}`.

## Decisiones de diseño

- **Pago simulado (mock), no Stripe real:** sin backend ni cuenta de Stripe. La secret key nunca iría en el cliente, así que se imita el flujo. Consistente con el enfoque "mock" del panel de administración (detección de espacios simulada).
- **Flujo de estados:** la reserva se crea en `pendiente` (antes era `activa`) y el espacio se retiene (`ocupado`) desde ese momento. El pago exitoso la pasa a `activa`.
  - **Éxito:** reserva → `activa` + registro de pago `exitoso`.
  - **Fallo (tarjeta declinada):** registro de pago `fallido`, la reserva sigue `pendiente` (se puede reintentar).
  - **Cancelar:** reserva → `cancelada` y el espacio se libera (`ocupado → libre`).
- **Simulación determinista por número de tarjeta (imita a Stripe):**
  - `4242 4242 4242 4242` → **éxito**
  - `4000 0000 0000 0002` → **declinada** (fallo)
  - Cualquier otra con formato válido → declinada ("tarjeta no reconocida").
  - Formato inválido (largo/expiración/CVC) → error de validación **antes** de "procesar": devuelve `ValidationFailure` y **no** escribe ningún documento en `pagos/`. (Distinto de una tarjeta declinada con formato válido, que sí registra un pago `fallido`.)
- **Persistencia:** nueva colección `pagos/` aparte (una colección por dominio, como `reservas`, `espacios`, `usuarios`). Permite guardar intentos fallidos por separado y, a futuro, un historial de pagos para el admin.
- **Navegación:** pantalla de pago como ruta dedicada `/pago/:reservaId`. Se le pasa la `ReservaEntity` por `extra` de GoRouter para mostrar el monto sin re-consultar Firestore.

## Fuera de alcance (YAGNI)

- Liberación automática por timeout de reservas `pendiente` no pagadas (cae en territorio del Módulo 6 / no-show).
- Vista de historial de pagos para el admin (la colección queda lista; se puede añadir luego).

## Qué se realizará

- **Core:** validadores nuevos en `lib/core/utils/validators.dart`: número de tarjeta (16 dígitos), expiración (`MM/YY` futura), CVC (3 dígitos).
- **Domain:**
  - `PagoEntity` (id, reservaId, usuarioId, monto, moneda, metodo, ultimos4, estado, transactionId?, fecha) + enum `EstadoPago { exitoso, fallido }`.
  - `PagoRepository` (interface): `procesarPago(...)`.
  - `ProcesarPagoUseCase`: valida tarjeta → decide éxito/fallo por número → en éxito crea el pago y pasa la reserva a `activa` (atómico vía repo/datasource); en fallo guarda pago `fallido` y devuelve `ValidationFailure`.
- **Data:**
  - `PagoModel` (`fromFirestore`/`toFirestore`/`fromEntity`, parseo de estado + Timestamp).
  - `PagoRemoteDatasource`: **transacción Firestore** que crea el doc en `pagos/` y actualiza `reservas/{id}.estado = activa` en una sola operación (solo en éxito). El pago fallido solo escribe en `pagos/`.
  - `PagoRepositoryImpl`.
- **Ajuste al Módulo 4:**
  - `CrearReservaUseCase` crea la reserva en `pendiente` (hoy `activa`).
  - `ReservaRepository` gana un método para **cancelar y liberar** el espacio (reserva → `cancelada`, espacio → `libre`), usado por el botón "Cancelar" de la pantalla de pago (transacción Firestore en el datasource de reservas).
- **Presentation:**
  - `PagoViewModel` (ChangeNotifier, estados idle/procesando/éxito/error).
  - `PagoView`: muestra el monto, formulario de tarjeta (número, expiración, CVC), botón "Pagar", spinner de procesamiento y pantalla de éxito/error; botón "Cancelar".
  - `parqueadero_detail_view` / `ReservaViewModel`: tras crear la reserva `pendiente`, navega a `/pago/:reservaId` con la `ReservaEntity`.
- **DI:** registrar `PagoRemoteDatasource`, `PagoRepository`, `ProcesarPagoUseCase` y `PagoViewModel` (factory) en `injection.dart`.
- **Router:** nueva ruta `/pago/:reservaId` en `app_router.dart`.
- **Firestore:** nueva colección `pagos/`.

## Tests (mocktail)

- `ProcesarPagoUseCase`:
  - tarjeta de éxito (`4242…`) → pago `exitoso` y la reserva pasa a `activa` (repo invocado).
  - tarjeta declinada (`4000…0002`) → `ValidationFailure`, la reserva **no** cambia; se registra pago `fallido`.
  - tarjeta con formato inválido → `ValidationFailure` sin tocar el repo.
  - el `monto` del pago == `reserva.montoTotal`.
- Actualizar el test existente del Módulo 4 (`crear_reserva_usecase_test.dart`) que hoy espera `estado: activa` → ahora `pendiente`.
