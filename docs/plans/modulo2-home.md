# Plan — Módulo 2: Home con Google Maps

**Objetivo:** Pantalla principal con mapa, ubicación actual del usuario y marcadores de parqueaderos cercanos desde Firestore.

## Qué se realizará

- Dependencias: google_maps_flutter, geolocator, flutter_dotenv
- Core: AppConstants (zoom, radio), LocationFailure
- Domain: ParqueaderoEntity, LocationRepository + ParqueaderoRepository (interfaces), GetCurrentLocationUseCase + GetParqueaderosCercanosUseCase
- Data: ParqueaderoModel, LocationLocalDatasource (wraps Geolocator), ParqueaderoRemoteDatasource (Firestore), LocationRepositoryImpl + ParqueaderoRepositoryImpl (Haversine filter)
- Presentation: HomeViewModel (ChangeNotifier), HomeView (GoogleMap full-screen), ParkingBottomSheet widget
- Android: permisos de ubicación + API Key Maps en AndroidManifest.xml via manifestPlaceholders
- Tests: GetParqueaderosCercanosUseCase (×2) — filtra correctamente / lista vacía si ninguno en radio
