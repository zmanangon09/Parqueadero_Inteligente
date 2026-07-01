# Plan — Módulo 4: Reserva

**Objetivo:** Desde el detalle del parqueadero, el usuario toca un espacio `libre`, elige placa y duración, confirma y el espacio pasa a `ocupado` en tiempo real. Se crea el documento `reservas/{id}`.

## Decisiones de diseño

- **Placa:** dropdown desde `UserEntity.vehiculos`. Si la lista está vacía (aún no existe el Módulo 8 - Perfil), fallback a campo de texto validado.
- **Espacio:** el usuario lo elige tocando un espacio `libre` del grid.
- **Tiempo:** reserva "ahora + duración". `fechaInicio = now`, `fechaFin = now + duración`.
- **Duración:** chips predefinidos (1h, 2h, 3h, 4h). `montoTotal = duraciónHoras × tarifaPorHora`.
- **Estado inicial:** `activa`. El espacio pasa `libre → ocupado`.
- **No-show (Módulo 6):** aquí solo se **modelan** los campos `limiteCheckIn = fechaInicio + 10min` y `checkInRealizado = false`. La liberación automática del espacio si no hay check-in se implementará en el Módulo 6 (QR).

## Qué se realizará

- Core: `Validators.placa` (formato placa ecuatoriana); reutilizado por dropdown y fallback de texto.
- Domain: `EstadoReserva` enum (`pendiente|activa|completada|cancelada`), `ReservaEntity` (id, usuarioId, espacioId, parqueaderoId, placa, fechaInicio, fechaFin, montoTotal, estado, limiteCheckIn, checkInRealizado, qrCode?), `ReservaRepository` (interface), `CrearReservaUseCase`.
- Data: `ReservaModel` (`fromFirestore`/`toFirestore`, parseo de estado + Timestamp), `ReservaRemoteDatasource` (**transacción Firestore**: lee espacio; si `estado != libre` lanza conflicto; si libre → marca `espacio.estado = ocupado` y crea doc `reservas/` en la misma transacción), `ReservaRepositoryImpl` (mapea conflicto a `ValidationFailure`).
- Presentation: `EspacioGrid` seleccionable (`onTap` solo en `libre` + borde de selección), `ReservaSheet` (bottom sheet: dropdown/campo placa, chips duración, resumen fin + monto, botón confirmar), `ReservaViewModel` (ChangeNotifier, estados idle/loading/success/error; usuario vía `AuthViewModel`). Botón placeholder de `parqueadero_detail_view.dart` abre el sheet.
- DI: registrar datasource, repositorio, use case y `ReservaViewModel` (factory) en `injection.dart`. Sin ruta nueva (sheet sobre el detalle).
- Firestore: nueva colección `reservas/`.
- Tests (mocktail): `CrearReservaUseCase` — reservar espacio disponible (éxito) / rechazar espacio ocupado (`ValidationFailure`); validación de placa vacía; cálculo correcto de `montoTotal`.
