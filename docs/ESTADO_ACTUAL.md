# Estado actual del proyecto — Control Inteligente de Parqueaderos

**Última actualización:** 2026-07-03

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
| 5 — Pago (simulado, estilo Stripe test-mode) | `docs/plans/modulo5-pago.md` | `docs/execution/modulo5-pago.md` | ✓ Completo (falta prueba manual E2E) |
| Admin — Panel de administración (registro de parqueaderos + dashboard) | — (trabajo de Andrea) | `Cambios_administrador.md` (raíz) | ✓ Integrado vía PR #1 |

**Flujo de trabajo usado en cada módulo:** presentar plan de 7 puntos → esperar aprobación del usuario ("lo apruebo") → implementar → correr tests → `dart analyze` sin errores → commit (sin atribución a Claude) → push.

## Pendiente

- **Módulo 6 — Check-in/Check-out (QR)**: siguiente paso. Aquí se activa la **liberación automática del no-show** — si no se hace check-in dentro de los 10 min (`reserva.limiteCheckIn`), el espacio vuelve a `libre`. Los campos `limiteCheckIn` y `checkInRealizado` ya están modelados en el Módulo 4. Nota: el Módulo 5 dejó reservas que pueden quedar en `pendiente` sin pagar (el espacio sigue retenido); su liberación por timeout también cae aquí.
- **Módulo 8 — Perfil**: agregar vehículos a `usuarios/{uid}.vehiculos`. Mientras no exista, el sheet de reserva usa un campo de texto de placa como fallback.

## Estado técnico verificado (2026-07-03, tras Módulo 5 - Pago)

- `flutter test` → **30/30 tests pasando** (18 previos + 8 validadores de tarjeta + 4 del `ProcesarPagoUseCase`)
- `flutter analyze` → **0 errores**. Avisos no bloqueantes: 2 `info` por `Radio` deprecado (`groupValue`/`onChanged`) en `lib/presentation/views/admin/review_parqueadero_view.dart` + 1 `warning` preexistente (`tLejano` en el test del Módulo 2)
- **Pendiente:** prueba manual end-to-end del flujo de pago en dispositivo/emulador (con tarjetas `4242…` éxito / `4000…0002` declinada)
- `git status` → working tree limpio

## Arquitectura (Clean Architecture + MVVM + Provider)

- **Domain**: entidades puras, repositorios abstractos, casos de uso devuelven `Either<Failure, T>` (dartz)
- **Data**: datasources (Firebase Auth, Firestore, Geolocator), modelos `fromFirestore`/`toFirestore`, implementaciones de repositorios
- **Presentation**: ViewModels (`ChangeNotifier`, sin acceso directo a Firebase), Views, Widgets reutilizables
- **DI**: `get_it` en `lib/core/di/injection.dart`
- **Navegación**: `go_router` con `refreshListenable` en `lib/core/router/app_router.dart`, rutas: `/login`, `/register`, `/home`, `/parking/:id`, `/pago/:reservaId`, `/admin_dashboard`, `/admin/add_parking`, `/admin/scan_parking`, `/admin/review_parking`. El `redirect` es por rol: si `isAdmin` → `/admin_dashboard`; si un cliente entra a una ruta `/admin/*` → lo devuelve a `/home`.
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
   - Colecciones esperadas: `parqueaderos`, `espacios`, `usuarios`, `reservas`, `pagos`
   - El usuario admin de prueba (`admin@parqueadero.com`) se auto-crea en Auth y en `usuarios/` al primer login (ver "Módulo de administración" abajo)

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

## Módulo de administración (integrado por Andrea vía PR #1, 2026-07-03)

Panel de admin aditivo — no modifica las vistas del cliente. Detalle completo en `Cambios_administrador.md` (raíz).

- **Acceso admin**: credencial de prueba **hardcodeada** `admin@parqueadero.com` / `adminparqueadero`. `auth_repository_impl.dart` tiene **auto-seed**: si la cuenta no existe en Firebase Auth la crea al primer login, y le asigna rol `admin` en `usuarios/`. ⚠️ Revisar/quitar antes de producción.
- **Pantallas** (`lib/presentation/views/admin/`): `admin_dashboard_view` (totales + historial de reservas), `add_parqueadero_view` (formulario + Google Maps interactivo), `scan_parqueadero_view` (cámara), `review_parqueadero_view` (grid editable de espacios antes de guardar).
- **Detección de espacios simulada (mock)**: `lib/core/services/detector_service.dart` NO usa TensorFlow real; devuelve un listado sugerido simulado sobre la foto capturada.
- **Guardado atómico**: `SaveParqueaderoUseCase` persiste el parqueadero + todos sus espacios en batch (colecciones `parqueaderos` y `espacios`), así aparece en el mapa del cliente sin cambios adicionales.
- **Dependencia nueva**: `image_picker: ^1.1.2` (cámara/galería). Puede requerir permiso `CAMERA` en `AndroidManifest.xml` y `NSCameraUsageDescription` en `Info.plist` para soporte completo.
- **`main.dart`**: pasó a `MultiProvider` para proveer `AddParqueaderoViewModel` globalmente (el estado del formulario sobrevive entre pantallas de GoRouter).
