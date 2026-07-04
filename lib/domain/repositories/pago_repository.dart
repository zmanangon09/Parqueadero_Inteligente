import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pago_entity.dart';

abstract class PagoRepository {
  /// Persiste el pago en `pagos/`. Si el pago es exitoso, además pasa la
  /// reserva asociada a `activa` en la misma transacción. Devuelve el pago
  /// persistido (con id) o un [Failure] ante error de infraestructura.
  Future<Either<Failure, PagoEntity>> registrarPago(PagoEntity pago);
}
