import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repo;
  const GetCurrentLocationUseCase(this._repo);

  Future<Either<Failure, (double lat, double lng)>> call() => _repo.getCurrentPosition();
}
