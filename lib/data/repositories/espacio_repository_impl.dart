import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/espacio_entity.dart';
import '../../domain/repositories/espacio_repository.dart';
import '../datasources/remote/espacio_remote_datasource.dart';

class EspacioRepositoryImpl implements EspacioRepository {
  final EspacioRemoteDatasource _datasource;
  EspacioRepositoryImpl(this._datasource);

  @override
  Stream<Either<Failure, List<EspacioEntity>>> watchEspaciosByParqueadero(
    String parqueaderoId,
  ) =>
      _datasource
          .watchEspaciosByParqueadero(parqueaderoId)
          .map<Either<Failure, List<EspacioEntity>>>(Right.new)
          .handleError(
            (e) => Left<Failure, List<EspacioEntity>>(
              ServerFailure('Error al cargar espacios: $e'),
            ),
          );
}
