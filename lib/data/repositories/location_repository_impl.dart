import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/local/location_local_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDatasource _datasource;
  LocationRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, (double lat, double lng)>> getCurrentPosition() async {
    try {
      final pos = await _datasource.getCurrentPosition();
      return Right(pos);
    } on LocationServiceDisabledException {
      return const Left(LocationFailure('El servicio de ubicación está desactivado.'));
    } on PermissionDeniedException catch (e) {
      return Left(LocationFailure(e.message ?? 'Permiso de ubicación denegado.'));
    } catch (_) {
      return const Left(LocationFailure('No se pudo obtener la ubicación.'));
    }
  }
}
