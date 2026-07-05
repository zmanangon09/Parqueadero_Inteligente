import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/reserva_entity.dart';

abstract class ReservaRepository {
  /// Crea la reserva de forma atómica: verifica que el espacio esté libre,
  /// lo marca como ocupado y persiste la reserva. Si el espacio ya no está
  /// disponible devuelve un [ValidationFailure].
  Future<Either<Failure, ReservaEntity>> crearReserva(ReservaEntity reserva);

  Future<Either<Failure, List<ReservaEntity>>> getAllReservas();

  Future<Either<Failure, List<ReservaEntity>>> getReservasByUsuario(
      String usuarioId);

  /// Cancela la reserva y libera su espacio (`ocupado → libre`) atómicamente.
  Future<Either<Failure, void>> cancelarReserva(ReservaEntity reserva);

  /// Busca la reserva por el contenido del QR (id del documento).
  /// Devuelve [ValidationFailure] si el QR no corresponde a ninguna reserva.
  Future<Either<Failure, ReservaEntity>> getReservaByQr(String qr);

  /// Marca `checkInRealizado = true`.
  Future<Either<Failure, void>> checkIn(ReservaEntity reserva);

  /// Completa la reserva y libera su espacio atómicamente.
  Future<Either<Failure, void>> checkOut(ReservaEntity reserva);

  /// No-show: cancela reservas con ventana de check-in vencida y libera
  /// sus espacios. Devuelve cuántas liberó.
  Future<Either<Failure, int>> liberarReservasExpiradas();
}
