import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/espacio_entity.dart';
import '../../repositories/espacio_repository.dart';

/// Evaluación de ocupación con la cámara (admin): a partir del número de
/// vehículos detectados por TFLite propone el nuevo estado de los espacios
/// y lo aplica en batch.
class ActualizarOcupacionUseCase {
  final EspacioRepository _repo;
  const ActualizarOcupacionUseCase(this._repo);

  /// Propuesta: los espacios `reservado` no se tocan (tienen una reserva
  /// vigente); los primeros [vehiculosDetectados] restantes (por número)
  /// quedan `ocupado` y el resto `libre`.
  ///
  /// ponytail: el modelo no ubica cada vehículo en su celda exacta (eso
  /// requeriría calibrar la cámara por parqueadero); se reparte por conteo.
  static List<EspacioEntity> sugerirOcupacion(
    List<EspacioEntity> espacios,
    int vehiculosDetectados,
  ) {
    var porAsignar = vehiculosDetectados;
    return [
      for (final e in espacios)
        if (e.estado == EstadoEspacio.reservado)
          e
        else
          EspacioEntity(
            id: e.id,
            parqueaderoId: e.parqueaderoId,
            numero: e.numero,
            estado: (porAsignar-- > 0)
                ? EstadoEspacio.ocupado
                : EstadoEspacio.libre,
            tipo: e.tipo,
          ),
    ];
  }

  /// Aplica la propuesta en Firestore.
  Future<Either<Failure, void>> call(
    String parqueaderoId,
    List<EspacioEntity> propuesta,
  ) {
    if (propuesta.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('No hay espacios que actualizar.')));
    }
    final disponibles =
        propuesta.where((e) => e.estado == EstadoEspacio.libre).length;
    return _repo.actualizarEstados(
      parqueaderoId,
      {for (final e in propuesta) e.id: e.estado},
      disponibles,
    );
  }
}
