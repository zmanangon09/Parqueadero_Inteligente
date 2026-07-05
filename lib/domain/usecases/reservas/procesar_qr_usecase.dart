import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/reserva_repository.dart';

enum QrAccion { checkIn, checkOut, noShow }

class QrResultado {
  final QrAccion accion;
  final ReservaEntity reserva;
  const QrResultado(this.accion, this.reserva);
}

/// Procesa el QR de una reserva en la puerta del parqueadero:
/// - Reserva activa sin check-in y dentro de la ventana → check-in.
/// - Reserva activa sin check-in y fuera de la ventana → no-show:
///   cancela la reserva y libera el espacio.
/// - Reserva activa con check-in → check-out (completa y libera).
class ProcesarQrUseCase {
  final ReservaRepository _repo;
  const ProcesarQrUseCase(this._repo);

  Future<Either<Failure, QrResultado>> call(String qr) async {
    final result = await _repo.getReservaByQr(qr.trim());

    return result.fold(Left.new, (reserva) async {
      switch (reserva.estado) {
        case EstadoReserva.pendiente:
          return const Left(ValidationFailure(
              'La reserva aún no está pagada. Completa el pago primero.'));
        case EstadoReserva.completada:
        case EstadoReserva.cancelada:
          return const Left(
              ValidationFailure('Esta reserva ya finalizó o fue cancelada.'));
        case EstadoReserva.activa:
          if (!reserva.checkInRealizado) {
            if (DateTime.now().isAfter(reserva.limiteCheckIn)) {
              final r = await _repo.cancelarReserva(reserva);
              return r.fold(
                  Left.new, (_) => Right(QrResultado(QrAccion.noShow, reserva)));
            }
            final r = await _repo.checkIn(reserva);
            return r.fold(
                Left.new, (_) => Right(QrResultado(QrAccion.checkIn, reserva)));
          }
          final r = await _repo.checkOut(reserva);
          return r.fold(
              Left.new, (_) => Right(QrResultado(QrAccion.checkOut, reserva)));
      }
    });
  }
}
