import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/espacio_entity.dart';

abstract class EspacioRepository {
  Stream<Either<Failure, List<EspacioEntity>>> watchEspaciosByParqueadero(
    String parqueaderoId,
  );

  Future<Either<Failure, List<EspacioEntity>>> getEspaciosByParqueadero(
    String parqueaderoId,
  );

  /// Actualiza en batch el estado de varios espacios y deja
  /// `espaciosDisponibles` del parqueadero en [espaciosDisponibles].
  Future<Either<Failure, void>> actualizarEstados(
    String parqueaderoId,
    Map<String, EstadoEspacio> estadoPorEspacioId,
    int espaciosDisponibles,
  );
}
