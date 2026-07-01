import 'package:dartz/dartz.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../entities/parqueadero_entity.dart';
import '../../repositories/parqueadero_repository.dart';

class GetParqueaderosCercanosParams {
  final double lat;
  final double lng;
  final double radiusKm;

  const GetParqueaderosCercanosParams({
    required this.lat,
    required this.lng,
    this.radiusKm = AppConstants.searchRadiusKm,
  });
}

class GetParqueaderosCercanosUseCase {
  final ParqueaderoRepository _repo;
  const GetParqueaderosCercanosUseCase(this._repo);

  Future<Either<Failure, List<ParqueaderoEntity>>> call(
    GetParqueaderosCercanosParams params,
  ) =>
      _repo.getParqueaderosCercanos(params.lat, params.lng, params.radiusKm);
}
