import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/espacio_entity.dart';

/// Una detección del modelo: clase COCO + confianza.
class VehicleDetection {
  final String label;
  final double score;
  const VehicleDetection(this.label, this.score);
}

/// Detección de vehículos con TensorFlow Lite — SSD MobileNet v1 (COCO,
/// cuantizado, entrada uint8 300x300). No se entrena nada: modelo
/// preentrenado empaquetado en `assets/models/detect.tflite`.
class SpaceDetectorService {
  /// Clases COCO que cuentan como vehículo ocupando un espacio.
  static const vehicleClasses = {'car', 'truck', 'bus', 'motorcycle'};

  static const _inputSize = 300;
  static const _numDetections = 10;
  static const double scoreThreshold = 0.5;

  /// Ruta a un `.tflite` en disco — solo para tests en host. En la app el
  /// modelo se carga desde assets.
  final String? modelFile;
  final String? labelsFile;

  Interpreter? _interpreter;
  List<String>? _labels;

  SpaceDetectorService({this.modelFile, this.labelsFile});

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    if (modelFile != null) {
      _interpreter = Interpreter.fromFile(File(modelFile!));
      _labels = File(labelsFile!).readAsLinesSync();
    } else {
      _interpreter =
          await Interpreter.fromAsset('assets/models/detect.tflite');
      _labels = (await rootBundle.loadString('assets/models/labelmap.txt'))
          .split('\n');
    }
  }

  /// Corre la inferencia y devuelve los vehículos detectados
  /// (car/truck/bus/motorcycle con score >= [scoreThreshold]).
  Future<List<VehicleDetection>> detectVehicles(String imagePath) async {
    await _ensureLoaded();

    final decoded = img.decodeImage(await File(imagePath).readAsBytes());
    if (decoded == null) {
      throw Exception('No se pudo decodificar la imagen capturada.');
    }
    final resized =
        img.copyResize(decoded, width: _inputSize, height: _inputSize);

    // Entrada uint8 [1, 300, 300, 3] en RGB.
    final input = [
      List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final p = resized.getPixel(x, y);
          return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
        }),
      ),
    ];

    // Salidas del modelo SSD: cajas, clases, scores y número de detecciones.
    final boxes =
        List.generate(1, (_) => List.generate(_numDetections, (_) => List.filled(4, 0.0)));
    final classes = List.generate(1, (_) => List.filled(_numDetections, 0.0));
    final scores = List.generate(1, (_) => List.filled(_numDetections, 0.0));
    final count = List.filled(1, 0.0);

    _interpreter!.runForMultipleInputs([input], {
      0: boxes,
      1: classes,
      2: scores,
      3: count,
    });

    final detections = <VehicleDetection>[];
    final n = count[0].toInt().clamp(0, _numDetections);
    for (var i = 0; i < n; i++) {
      if (scores[0][i] < scoreThreshold) continue;
      // labelmap.txt arranca con '???' → la clase c corresponde a la línea c+1.
      final idx = classes[0][i].toInt() + 1;
      if (idx < 0 || idx >= _labels!.length) continue;
      final label = _labels![idx].trim();
      if (vehicleClasses.contains(label)) {
        detections.add(VehicleDetection(label, scores[0][i]));
      }
    }
    return detections;
  }

  /// Para el registro de un parqueadero nuevo: cada vehículo detectado en la
  /// foto es un espacio ocupado. Los espacios libres los agrega/ajusta el
  /// administrador en la pantalla de revisión.
  Future<List<EspacioEntity>> detectSpaces(String imagePath) async {
    final detections = await detectVehicles(imagePath);
    return [
      for (var i = 0; i < detections.length; i++)
        EspacioEntity(
          id: '',
          parqueaderoId: '',
          numero: i + 1,
          estado: EstadoEspacio.ocupado,
          tipo: TipoEspacio.normal,
        ),
    ];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
