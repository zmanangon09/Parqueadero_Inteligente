import 'package:flutter_test/flutter_test.dart';
import 'package:pry_final_parqueadero/core/services/detector_service.dart';
import 'package:pry_final_parqueadero/domain/entities/espacio_entity.dart';

/// Prueba de integración REAL del modelo TensorFlow Lite (SSD MobileNet v1
/// COCO cuantizado): corre inferencia sobre una foto con vehículos y
/// verifica que detecta al menos uno.
///
/// Requiere `libtensorflowlite_c-win.dll` en
/// `<flutter>/bin/cache/artifacts/engine/windows-x64/blobs/` para correr en
/// host Windows; en Android/iOS la librería viene con el plugin.
void main() {
  final service = SpaceDetectorService(
    modelFile: 'assets/models/detect.tflite',
    labelsFile: 'assets/models/labelmap.txt',
  );

  tearDownAll(service.dispose);

  test('detectVehicles encuentra vehículos en una foto real', () async {
    final detections =
        await service.detectVehicles('test/fixtures/vehiculos.jpg');

    // La foto (bus.jpg) contiene un bus grande en primer plano.
    expect(detections, isNotEmpty,
        reason: 'El modelo debe detectar al menos un vehículo');
    expect(
      detections.every(
          (d) => SpaceDetectorService.vehicleClasses.contains(d.label)),
      isTrue,
      reason: 'Solo deben reportarse clases de vehículo',
    );
    expect(
      detections.every((d) => d.score >= SpaceDetectorService.scoreThreshold),
      isTrue,
    );
  });

  test('detectSpaces marca un espacio ocupado por cada vehículo', () async {
    final spaces = await service.detectSpaces('test/fixtures/vehiculos.jpg');

    expect(spaces, isNotEmpty);
    expect(spaces.every((e) => e.estado == EstadoEspacio.ocupado), isTrue);
    // Numeración consecutiva desde 1.
    expect(spaces.first.numero, 1);
    expect(spaces.last.numero, spaces.length);
  });
}
