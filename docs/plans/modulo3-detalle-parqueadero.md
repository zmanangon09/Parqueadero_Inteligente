# Plan — Módulo 3: Detalle de Parqueadero

**Objetivo:** Pantalla de detalle con información del parqueadero, grid de espacios con estado en tiempo real via Firestore snapshots().

## Qué se realizará

- Domain: EspacioEntity (estado/tipo enums), EspacioRepository (interface con Stream), GetParqueaderoByIdUseCase, WatchEspaciosUseCase
- Data: EspacioModel (fromFirestore), EspacioRemoteDatasource (snapshots()), EspacioRepositoryImpl; ampliar ParqueaderoRepository/Datasource/Impl con getById()
- Presentation: ParqueaderoDetailViewModel (StreamSubscription + dispose), ParqueaderoDetailView, EspacioGrid widget (colores por estado: teal/rojo/ámbar)
- Router: ruta `/parking/:id`, ParkingBottomSheet conectado a navegación
- Tests: WatchEspaciosUseCase — stream emite lista correcta / stream emite Failure
