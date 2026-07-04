import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../entities/pago_entity.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/pago_repository.dart';

class ProcesarPagoUseCase {
  final PagoRepository _repo;
  const ProcesarPagoUseCase(this._repo);

  /// Tarjeta de prueba que simula un pago aprobado (estilo Stripe test mode).
  static const tarjetaExito = '4242424242424242';

  Future<Either<Failure, PagoEntity>> call({
    required ReservaEntity reserva,
    required String numeroTarjeta,
    required String expiracion,
    required String cvc,
  }) async {
    final numeroError = Validators.numeroTarjeta(numeroTarjeta);
    if (numeroError != null) return Left(ValidationFailure(numeroError));
    final expError = Validators.expiracionTarjeta(expiracion);
    if (expError != null) return Left(ValidationFailure(expError));
    final cvcError = Validators.cvc(cvc);
    if (cvcError != null) return Left(ValidationFailure(cvcError));

    final numero = numeroTarjeta.replaceAll(RegExp(r'\s'), '');
    final aprobado = numero == tarjetaExito;
    final ahora = DateTime.now();

    final pago = PagoEntity(
      id: '',
      reservaId: reserva.id,
      usuarioId: reserva.usuarioId,
      monto: reserva.montoTotal,
      ultimos4: numero.substring(numero.length - 4),
      estado: aprobado ? EstadoPago.exitoso : EstadoPago.fallido,
      transactionId: aprobado ? 'sim_${ahora.millisecondsSinceEpoch}' : null,
      fecha: ahora,
    );

    final result = await _repo.registrarPago(pago);
    return result.fold(
      (failure) => Left(failure),
      (saved) => saved.estado == EstadoPago.exitoso
          ? Right(saved)
          : const Left(ValidationFailure(
              'Tarjeta declinada. Verifica los datos o usa otra tarjeta.')),
    );
  }
}
