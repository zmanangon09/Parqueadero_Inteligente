import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/reserva_repository.dart';

/// Historial del usuario: sus reservas ordenadas de más reciente a más antigua.
class GetReservasUsuarioUseCase {
  final ReservaRepository _repo;
  const GetReservasUsuarioUseCase(this._repo);

  Future<Either<Failure, List<ReservaEntity>>> call(String usuarioId) =>
      _repo.getReservasByUsuario(usuarioId);
}
