# Ejecución — Módulo 4: Reserva

**Estado:** Completado ✓  
**Fecha:** 2026-07-01

## Flujo implementado

1. En el detalle del parqueadero, el usuario toca un espacio `libre` del grid → se marca con borde teal (selección).
2. El botón inferior pasa de "Selecciona un espacio libre" (deshabilitado) a "Reservar espacio N".
3. Al pulsarlo se abre `ReservaSheet`: placa (dropdown desde `vehiculos` o campo de texto si la lista está vacía), chips de duración (1-4 h) y total a pagar (duración × tarifa).
4. Confirmar → transacción Firestore: si el espacio sigue `libre`, se marca `ocupado` y se crea `reservas/{id}` con estado `activa`. El grid se actualiza en tiempo real (snapshots) y la selección se limpia sola.
5. Si el espacio ya no está libre (otro usuario reservó primero), se rechaza con `ValidationFailure` y se muestra SnackBar de error.

## Archivos creados

### Domain
- `lib/domain/entities/reserva_entity.dart` — ReservaEntity + enum EstadoReserva (pendiente/activa/completada/cancelada). Campos de no-show: `limiteCheckIn`, `checkInRealizado`, `qrCode?` (para Módulo 6)
- `lib/domain/repositories/reserva_repository.dart` — interface `crearReserva`
- `lib/domain/usecases/reservas/crear_reserva_usecase.dart` — valida placa/duración, calcula fechaFin, montoTotal y limiteCheckIn (+10 min), construye la reserva `activa`

### Data
- `lib/data/models/reserva_model.dart` — fromFirestore/toFirestore/fromEntity, parseo de estado y Timestamp
- `lib/data/datasources/remote/reserva_remote_datasource.dart` — transacción Firestore (verifica libre → ocupado + crea reserva); `EspacioNoDisponibleException`
- `lib/data/repositories/reserva_repository_impl.dart` — mapea el conflicto a `ValidationFailure`

### Presentation
- `lib/presentation/viewmodels/reserva_viewmodel.dart` — estados idle/loading/success/error
- `lib/presentation/widgets/reserva_sheet.dart` — bottom sheet de reserva

## Archivos actualizados
- `lib/core/utils/validators.dart` — agrega `Validators.placa` (formato placa ecuatoriana)
- `lib/presentation/widgets/espacio_grid.dart` — grid seleccionable (`onTap` solo en libres + borde de selección)
- `lib/presentation/viewmodels/parqueadero_detail_viewmodel.dart` — selección de espacio (`selectEspacio`, se limpia si deja de estar libre)
- `lib/presentation/views/parking/parqueadero_detail_view.dart` — conecta botón "Reservar" → abre el sheet con el usuario actual (`AuthViewModel`)
- `lib/core/di/injection.dart` — registra datasource, repositorio, `CrearReservaUseCase` y `ReservaViewModel`

## Decisiones
- Reserva "ahora + duración": `fechaInicio = now`, `fechaFin = now + duración`. Estado inicial `activa`, espacio → `ocupado`.
- Regla de no-show (liberar si no hay check-in en 10 min): solo se **modelan** los campos aquí; la liberación automática se implementa en el Módulo 6 (QR).
- Fallback de placa por campo de texto porque el Módulo 8 (Perfil) que agrega vehículos aún no existe.

## Tests
- `test/domain/usecases/reservas/crear_reserva_usecase_test.dart` — 5 tests: reservar disponible ✓, rechazar ocupado (ValidationFailure) ✓, placa inválida sin llamar al repo ✓, cálculo de montoTotal ✓, construcción con estado activa + límite +10 min ✓
- **Total acumulado: 18/18 tests en verde**

## Firestore
- Nueva colección `reservas/` con campos: usuarioId, espacioId, parqueaderoId, placa, fechaInicio, fechaFin, montoTotal, estado, limiteCheckIn, checkInRealizado, qrCode.
