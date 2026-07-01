import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/parqueadero_entity.dart';
import '../../repositories/parqueadero_repository.dart';

class GetParqueaderoByIdUseCase {
  final ParqueaderoRepository _repo;
  const GetParqueaderoByIdUseCase(this._repo);

  Future<Either<Failure, ParqueaderoEntity>> call(String id) =>
      _repo.getById(id);
}
