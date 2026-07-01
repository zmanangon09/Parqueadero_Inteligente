# Ejecución — Módulo 2: Home con Google Maps

**Estado:** Completado ✓  
**Fecha:** 2026-06-30

## Archivos creados

### Core
- `lib/core/constants/app_constants.dart` — zoom default (14), radio (5km), coordenadas fallback Bogotá
- `lib/core/errors/failures.dart` — añadido `LocationFailure`

### Domain
- `lib/domain/entities/parqueadero_entity.dart` — ParqueaderoEntity + getter `tieneEspacios`
- `lib/domain/repositories/location_repository.dart` — interface: getCurrentPosition() → (lat, lng)
- `lib/domain/repositories/parqueadero_repository.dart` — interface: getParqueaderosCercanos(lat, lng, km)
- `lib/domain/usecases/location/get_current_location_usecase.dart`
- `lib/domain/usecases/parking/get_parqueaderos_cercanos_usecase.dart` — params con radiusKm default

### Data
- `lib/data/models/parqueadero_model.dart` — fromFirestore (GeoPoint), toFirestore
- `lib/data/datasources/local/location_local_datasource.dart` — wraps Geolocator, pide permisos
- `lib/data/datasources/remote/parqueadero_remote_datasource.dart` — colección `parqueaderos/`
- `lib/data/repositories/location_repository_impl.dart` — mapea excepciones Geolocator → LocationFailure
- `lib/data/repositories/parqueadero_repository_impl.dart` — filtra por distancia Haversine

### Presentation
- `lib/presentation/viewmodels/home_viewmodel.dart` — HomeStatus enum, init(), refresh(), selectParqueadero()
- `lib/presentation/views/home/home_view.dart` — GoogleMap full-screen, TopBar, FABs, overlays
- `lib/presentation/widgets/parking_bottom_sheet.dart` — info chips (espacios, tarifa, horario) + CTA

### Actualizado
- `lib/core/di/injection.dart` — registra LocationDatasource, ParqueaderoDatasource, repos, use cases, HomeViewModel
- `lib/core/router/app_router.dart` — reemplaza placeholder con HomeView + ChangeNotifierProvider
- `lib/main.dart` — añade `dotenv.load()`
- `android/app/src/main/AndroidManifest.xml` — permisos ubicación + meta-data MAPS_API_KEY
- `android/app/build.gradle.kts` — lee MAPS_API_KEY de local.properties → manifestPlaceholders
- `pubspec.yaml` — google_maps_flutter, geolocator, flutter_dotenv; assets: .env

## Configuración requerida (usuario)
1. Agregar a `android/local.properties`:
   ```
   MAPS_API_KEY=tu_google_maps_api_key
   ```
2. Habilitar Maps SDK for Android en Google Cloud Console para el proyecto Firebase

## Tests
- `test/domain/usecases/parking/get_parqueaderos_cercanos_usecase_test.dart` — 3 tests ✓
- **Total acumulado: 10/10 tests en verde**
