# Estado actual del proyecto — Control Inteligente de Parqueaderos

**Última actualización:** 2026-07-01

## Repositorio

- Remoto: https://github.com/zmanangon09/Parqueadero_Inteligente.git
- Branch: `main`, sincronizado con origin (sin cambios pendientes)
- **Regla de commits:** nunca incluir `Co-Authored-By: Claude` — el usuario pidió explícitamente que no se vea que la IA hizo los commits. Usar sus credenciales de git normales.

## Cómo retomar el trabajo

1. Lee `docs/plans/` — un `.md` por módulo con el plan de 7 puntos aprobado antes de implementar.
2. Lee `docs/execution/` — un `.md` por módulo con lo que realmente se implementó (archivos creados/modificados, tests).
3. `git log --oneline` para ver el historial de commits (uno por módulo/feature).

## Módulos completados

| Módulo | Plan | Ejecución | Estado |
|--------|------|-----------|--------|
| 1 — Autenticación (Firebase Auth Email/Password) | `docs/plans/modulo1-autenticacion.md` | `docs/execution/modulo1-autenticacion.md` | ✓ Completo |
| 2 — Home con Google Maps | `docs/plans/modulo2-home.md` | `docs/execution/modulo2-home.md` | ✓ Completo |
| 3 — Detalle de parqueadero (espacios en tiempo real) | `docs/plans/modulo3-detalle-parqueadero.md` | `docs/execution/modulo3-detalle-parqueadero.md` | ✓ Completo |
| 4 — Reserva (transacción Firestore, no-show modelado) | `docs/plans/modulo4-reserva.md` | `docs/execution/modulo4-reserva.md` | ✓ Completo |

**Flujo de trabajo usado en cada módulo:** presentar plan de 7 puntos → esperar aprobación del usuario ("lo apruebo") → implementar → correr tests → `dart analyze` sin errores → commit (sin atribución a Claude) → push.

## Pendiente

- **Módulo 5 — Pago (Stripe Test Mode)**: siguiente paso. Confirmación de pago sobre la reserva creada en el Módulo 4 (`montoTotal` ya calculado).
- **Módulo 6 — Check-in/Check-out (QR)**: aquí se activa la **liberación automática del no-show** — si no se hace check-in dentro de los 10 min (`reserva.limiteCheckIn`), el espacio vuelve a `libre`. Los campos `limiteCheckIn` y `checkInRealizado` ya están modelados en el Módulo 4.
- **Módulo 8 — Perfil**: agregar vehículos a `usuarios/{uid}.vehiculos`. Mientras no exista, el sheet de reserva usa un campo de texto de placa como fallback.

## Estado técnico verificado (2026-07-01)

- `flutter test` → **18/18 tests pasando** (13 previos + 5 del Módulo 4)
- `dart analyze lib/` → sin issues. `dart analyze test/` → 1 warning preexistente (`tLejano` sin usar en el test del Módulo 2, ajeno al Módulo 4)
- `git status` → working tree limpio

## Arquitectura (Clean Architecture + MVVM + Provider)

- **Domain**: entidades puras, repositorios abstractos, casos de uso devuelven `Either<Failure, T>` (dartz)
- **Data**: datasources (Firebase Auth, Firestore, Geolocator), modelos `fromFirestore`/`toFirestore`, implementaciones de repositorios
- **Presentation**: ViewModels (`ChangeNotifier`, sin acceso directo a Firebase), Views, Widgets reutilizables
- **DI**: `get_it` en `lib/core/di/injection.dart`
- **Navegación**: `go_router` con `refreshListenable` en `lib/core/router/app_router.dart`, rutas: `/login`, `/register`, `/home`, `/parking/:id`
- **Tema**: Material 3, paleta Trust Teal (`#0F766E` primario), fuentes Outfit (títulos) + Work Sans (cuerpo)

## Configuración de entorno (necesaria en máquina nueva)

Estos archivos están gitignored y **no se subieron** al repo — hay que recrearlos en cada máquina:

1. **`.env`** (raíz del proyecto):
   ```
   GOOGLE_MAPS_API_KEY=<tu-key>
   ```
2. **`android/local.properties`** — agregar línea:
   ```
   MAPS_API_KEY=<tu-key>
   ```
3. **`lib/firebase_options.dart`** — generado por `flutterfire configure` (proyecto Firebase: `smart-parking-mrcc`). Si falta, correr `flutterfire configure` y seleccionar ese proyecto.
4. **Firebase Console** (proyecto `smart-parking-mrcc`):
   - Authentication → Sign-in method → Email/Password debe estar **habilitado**
   - Firestore Database → debe existir la base `(default)` en modo de prueba
   - Colecciones esperadas: `parqueaderos`, `espacios`, `usuarios`, `reservas`

## Datos de prueba en Firestore (para probar Módulo 2 y 3)

### Colección `parqueaderos` (1 documento de ejemplo)
| Campo | Tipo | Valor |
|-------|------|-------|
| nombre | string | Parqueadero Centro Norte |
| direccion | string | Av. 10 de Agosto y Colón, Quito |
| ubicacion | **geopoint** | lat -0.2105, lng -78.4914 |
| capacidadTotal | number | 20 |
| espaciosDisponibles | number | 12 |
| tarifaPorHora | number | 1.5 |
| horario | string | 06:00 - 22:00 |
| adminId | string | admin001 |

### Colección `espacios` (5 documentos, mismo `parqueaderoId` = ID del parqueadero de arriba)
| numero | estado | tipo |
|--------|--------|------|
| 1 | libre | normal |
| 2 | ocupado | normal |
| 3 | libre | discapacitado |
| 4 | reservado | normal |
| 5 | libre | electrico |

Valores válidos: `estado` ∈ {libre, ocupado, reservado}; `tipo` ∈ {normal, discapacitado, electrico}.

Fallback de ubicación GPS (si no hay permisos/GPS): Quito, `-0.1807, -78.4678`. Radio de búsqueda: 5 km (`AppConstants.searchRadiusKm`).

## Notas de sesión / decisiones tomadas

- App recuerda sesión de Firebase entre reinicios (comportamiento esperado) → se agregó botón de logout en `HomeView` (`_TopBar`, icono superior derecho) para poder cerrar sesión manualmente.
- Firestore no soporta geo-queries nativas → filtro de cercanía se hace client-side con fórmula de Haversine en `lib/data/repositories/parqueadero_repository_impl.dart`.
- Espacios en tiempo real usan `snapshots()` de Firestore envuelto en `Stream<Either<Failure, List<EspacioEntity>>>`, con `StreamSubscription` cancelada en `dispose()` de `ParqueaderoDetailViewModel`.
