import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/parqueadero_entity.dart';

abstract class ParqueaderoRepository {
  Future<Either<Failure, List<ParqueaderoEntity>>> getParqueaderosCercanos(
    double lat,
    double lng,
    double radiusKm,
  );
}
