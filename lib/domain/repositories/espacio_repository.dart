import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/espacio_entity.dart';

abstract class EspacioRepository {
  Stream<Either<Failure, List<EspacioEntity>>> watchEspaciosByParqueadero(
    String parqueaderoId,
  );
}
