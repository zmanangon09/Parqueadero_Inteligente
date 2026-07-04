import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/reserva_repository.dart';

class CancelarReservaUseCase {
  final ReservaRepository _repo;
  const CancelarReservaUseCase(this._repo);

  Future<Either<Failure, void>> call(ReservaEntity reserva) =>
      _repo.cancelarReserva(reserva);
}
