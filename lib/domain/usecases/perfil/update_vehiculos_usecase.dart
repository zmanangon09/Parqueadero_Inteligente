import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateVehiculosUseCase {
  final AuthRepository _repo;
  const UpdateVehiculosUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call(
      String uid, List<String> vehiculos) async {
    for (final placa in vehiculos) {
      final error = Validators.placa(placa);
      if (error != null) return Left(ValidationFailure(error));
    }
    final normalizadas =
        vehiculos.map((p) => p.trim().toUpperCase()).toSet().toList();
    return _repo.updateVehiculos(uid, normalizadas);
  }
}
