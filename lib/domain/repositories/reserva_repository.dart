import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/reserva_entity.dart';

abstract class ReservaRepository {
  /// Crea la reserva de forma atómica: verifica que el espacio esté libre,
  /// lo marca como ocupado y persiste la reserva. Si el espacio ya no está
  /// disponible devuelve un [ValidationFailure].
  Future<Either<Failure, ReservaEntity>> crearReserva(ReservaEntity reserva);
}
