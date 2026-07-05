import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/reserva_repository.dart';

/// Liberación automática por no-show: cancela reservas sin check-in cuya
/// ventana (`limiteCheckIn`) ya venció y devuelve sus espacios a `libre`.
class LiberarReservasExpiradasUseCase {
  final ReservaRepository _repo;
  const LiberarReservasExpiradasUseCase(this._repo);

  Future<Either<Failure, int>> call() => _repo.liberarReservasExpiradas();
}
