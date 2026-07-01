import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/remote/reserva_remote_datasource.dart';
import '../models/reserva_model.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaRemoteDatasource _datasource;
  ReservaRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, ReservaEntity>> crearReserva(
    ReservaEntity reserva,
  ) async {
    try {
      final creada =
          await _datasource.crearReserva(ReservaModel.fromEntity(reserva));
      return Right(creada);
    } on EspacioNoDisponibleException {
      return const Left(ValidationFailure('El espacio ya no está disponible.'));
    } catch (e) {
      return Left(ServerFailure('Error al crear la reserva: $e'));
    }
  }
}
