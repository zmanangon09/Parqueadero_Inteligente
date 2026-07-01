import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/reserva_repository.dart';

class CrearReservaUseCase {
  final ReservaRepository _repo;
  const CrearReservaUseCase(this._repo);

  /// Ventana de gracia para hacer check-in antes de que el espacio se libere
  /// automáticamente (la liberación se implementa en el Módulo 6 - QR).
  static const Duration gracePeriod = Duration(minutes: 10);

  Future<Either<Failure, ReservaEntity>> call({
    required String usuarioId,
    required String espacioId,
    required String parqueaderoId,
    required String placa,
    required int duracionHoras,
    required double tarifaPorHora,
  }) async {
    final placaError = Validators.placa(placa);
    if (placaError != null) return Left(ValidationFailure(placaError));

    if (duracionHoras <= 0) {
      return const Left(ValidationFailure('La duración debe ser mayor a 0.'));
    }

    final inicio = DateTime.now();
    final reserva = ReservaEntity(
      id: '',
      usuarioId: usuarioId,
      espacioId: espacioId,
      parqueaderoId: parqueaderoId,
      placa: placa.trim(),
      fechaInicio: inicio,
      fechaFin: inicio.add(Duration(hours: duracionHoras)),
      montoTotal: duracionHoras * tarifaPorHora,
      estado: EstadoReserva.activa,
      limiteCheckIn: inicio.add(gracePeriod),
      checkInRealizado: false,
    );

    return _repo.crearReserva(reserva);
  }
}
