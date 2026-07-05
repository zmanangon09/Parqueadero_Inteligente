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

  @override
  Future<Either<Failure, List<EspacioEntity>>> getEspaciosByParqueadero(
    String parqueaderoId,
  ) async {
    try {
      final list = await _datasource.getEspaciosByParqueadero(parqueaderoId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Error al cargar espacios: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> actualizarEstados(
    String parqueaderoId,
    Map<String, EstadoEspacio> estadoPorEspacioId,
    int espaciosDisponibles,
  ) async {
    try {
      await _datasource.actualizarEstados(
        parqueaderoId,
        estadoPorEspacioId.map((id, e) => MapEntry(id, e.name)),
        espaciosDisponibles,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar ocupación: $e'));
    }
  }
}
