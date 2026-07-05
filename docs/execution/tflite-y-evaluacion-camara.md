# Ejecución — TensorFlow Lite real + Evaluación de ocupación con cámara (admin)

## TFLite real (reemplaza el mock)
- `lib/core/services/detector_service.dart` ahora usa **tflite_flutter** con **SSD MobileNet v1 COCO cuantizado** (entrada uint8 300×300), empaquetado en `assets/models/detect.tflite` + `labelmap.txt` (descargados de los modelos hosted de TensorFlow; no se entrena nada).
- `detectVehicles(imagePath)`: decodifica/redimensiona con el paquete `image`, corre la inferencia y filtra clases `car`, `truck`, `bus`, `motorcycle` con score ≥ 0.5.
- `detectSpaces(imagePath)` (flujo "Nuevo Parqueadero"): cada vehículo detectado = un espacio `ocupado`; los libres los agrega el admin en la pantalla de revisión (el modelo detecta vehículos, no celdas vacías — coherente con la especificación).

## Prueba real del modelo
- `test/core/services/detector_service_test.dart` corre **inferencia real** sobre `test/fixtures/vehiculos.jpg` (bus en primer plano) y verifica detecciones.
- Para que corra en Windows (host) se instaló `libtensorflowlite_c-win.dll` en `<flutter>/bin/cache/artifacts/engine/windows-x64/blobs/`. En Android/iOS la librería nativa viene con el plugin.
- Resultado: pasa (el modelo detecta el bus con score ≥ 0.5).

## Evaluación de espacios libres con cámara (panel admin)
- Dashboard → icono de cámara junto a cada parqueadero → `/admin/evaluate/:id`.
- Flujo: foto con la cámara → TFLite cuenta vehículos → propuesta de estados:
  - espacios `reservado` **no se tocan** (tienen reserva vigente);
  - los primeros N restantes (por número) quedan `ocupado`, el resto `libre`.
  - ponytail: se reparte por conteo; ubicar cada vehículo en su celda exacta requeriría calibrar la cámara por parqueadero.
- "Aplicar ocupación" hace batch update de `espacios` y deja `espaciosDisponibles` = libres.

## Archivos
- Creados: `actualizar_ocupacion_usecase.dart`, `get_espacios_parqueadero_usecase.dart`, `evaluar_ocupacion_viewmodel.dart`, `views/admin/evaluar_ocupacion_view.dart`, tests (`detector_service_test.dart`, `actualizar_ocupacion_usecase_test.dart`).
- Modificados: `detector_service.dart` (reescrito con TFLite), `espacio_remote_datasource.dart` / `espacio_repository(.dart|_impl.dart)` (+get one-shot, +batch update), `admin_dashboard_view.dart`, `app_router.dart`, `injection.dart`, `pubspec.yaml` (tflite_flutter, image, assets/models).
