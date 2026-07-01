import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/espacio_entity.dart';
import '../../repositories/espacio_repository.dart';

class WatchEspaciosUseCase {
  final EspacioRepository _repo;
  const WatchEspaciosUseCase(this._repo);

  Stream<Either<Failure, List<EspacioEntity>>> call(String parqueaderoId) =>
      _repo.watchEspaciosByParqueadero(parqueaderoId);
}
