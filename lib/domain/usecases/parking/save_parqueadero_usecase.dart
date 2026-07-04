import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/espacio_entity.dart';
import '../../entities/parqueadero_entity.dart';
import '../../repositories/parqueadero_repository.dart';

class SaveParqueaderoUseCase {
  final ParqueaderoRepository _repository;
  const SaveParqueaderoUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required ParqueaderoEntity parqueadero,
    required List<EspacioEntity> espacios,
  }) =>
      _repository.saveParqueadero(parqueadero, espacios);
}
