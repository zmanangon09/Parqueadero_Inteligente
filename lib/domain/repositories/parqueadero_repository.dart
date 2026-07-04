import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/espacio_entity.dart';
import '../entities/parqueadero_entity.dart';

abstract class ParqueaderoRepository {
  Future<Either<Failure, List<ParqueaderoEntity>>> getParqueaderosCercanos(
    double lat,
    double lng,
    double radiusKm,
  );

  Future<Either<Failure, ParqueaderoEntity>> getById(String id);

  Future<Either<Failure, Unit>> saveParqueadero(
    ParqueaderoEntity parqueadero,
    List<EspacioEntity> espacios,
  );

  Future<Either<Failure, int>> getParqueaderosCount();
}
