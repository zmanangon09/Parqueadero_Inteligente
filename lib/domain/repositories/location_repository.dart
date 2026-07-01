import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

abstract class LocationRepository {
  Future<Either<Failure, (double lat, double lng)>> getCurrentPosition();
}
