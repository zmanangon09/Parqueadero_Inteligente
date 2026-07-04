import 'dart:math';
import '../../domain/entities/espacio_entity.dart';

class SpaceDetectorService {
  Future<List<EspacioEntity>> detectSpaces(String imagePath) async {
    // Simula el tiempo de procesamiento de la red neuronal TensorFlow Lite
    await Future<void>.delayed(const Duration(seconds: 2));

    final random = Random();
    final List<EspacioEntity> spaces = [];
    
    // Generar un número aleatorio de espacios entre 10 y 20
    final totalSpaces = 10 + random.nextInt(11); // 10 a 20

    for (int i = 1; i <= totalSpaces; i++) {
      // 70% de probabilidad de estar libre, 30% ocupado
      final isOcupado = random.nextDouble() < 0.3;
      
      // Tipo de espacio (90% normal, 5% discapacitado, 5% eléctrico)
      final typeSelector = random.nextDouble();
      final tipo = typeSelector < 0.90
          ? TipoEspacio.normal
          : typeSelector < 0.95
              ? TipoEspacio.discapacitado
              : TipoEspacio.electrico;

      spaces.add(
        EspacioEntity(
          id: '', // Se generará en Firestore al guardar
          parqueaderoId: '', // Se asignará al asociar al parqueadero
          numero: i,
          estado: isOcupado ? EstadoEspacio.ocupado : EstadoEspacio.libre,
          tipo: tipo,
        ),
      );
    }

    return spaces;
  }
}
