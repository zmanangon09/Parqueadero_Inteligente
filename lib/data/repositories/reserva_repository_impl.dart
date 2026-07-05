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

  @override
  Future<Either<Failure, List<ReservaEntity>>> getAllReservas() async {
    try {
      final list = await _datasource.getAllReservas();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Error al cargar historial de reservas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReservaEntity>>> getReservasByUsuario(
    String usuarioId,
  ) async {
    try {
      final list = await _datasource.getReservasByUsuario(usuarioId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Error al cargar tus reservas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelarReserva(ReservaEntity reserva) async {
    try {
      await _datasource.cancelarReserva(ReservaModel.fromEntity(reserva));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al cancelar la reserva: $e'));
    }
  }

  @override
  Future<Either<Failure, ReservaEntity>> getReservaByQr(String qr) async {
    try {
      final reserva = await _datasource.getReservaByQr(qr);
      if (reserva == null) {
        return const Left(
            ValidationFailure('El código QR no corresponde a una reserva.'));
      }
      return Right(reserva);
    } catch (e) {
      return Left(ServerFailure('Error al leer el QR: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> checkIn(ReservaEntity reserva) async {
    try {
      await _datasource.checkIn(ReservaModel.fromEntity(reserva));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al hacer check-in: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> checkOut(ReservaEntity reserva) async {
    try {
      await _datasource.checkOut(ReservaModel.fromEntity(reserva));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al hacer check-out: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> liberarReservasExpiradas() async {
    try {
      final n = await _datasource.liberarReservasExpiradas();
      return Right(n);
    } catch (e) {
      return Left(ServerFailure('Error al liberar reservas expiradas: $e'));
    }
  }
}
