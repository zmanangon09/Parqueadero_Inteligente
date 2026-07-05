import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/espacio_entity.dart';
import '../../repositories/espacio_repository.dart';

/// Lectura puntual (no stream) de los espacios de un parqueadero.
class GetEspaciosParqueaderoUseCase {
  final EspacioRepository _repo;
  const GetEspaciosParqueaderoUseCase(this._repo);

  Future<Either<Failure, List<EspacioEntity>>> call(String parqueaderoId) =>
      _repo.getEspaciosByParqueadero(parqueaderoId);
}
