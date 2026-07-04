import 'package:flutter/foundation.dart';

import '../../domain/entities/pago_entity.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/usecases/pagos/procesar_pago_usecase.dart';
import '../../domain/usecases/reservas/cancelar_reserva_usecase.dart';

enum PagoStatus { idle, procesando, exito, error }

class PagoViewModel extends ChangeNotifier {
  final ProcesarPagoUseCase _procesarPago;
  final CancelarReservaUseCase _cancelarReserva;

  PagoViewModel({
    required ProcesarPagoUseCase procesarPagoUseCase,
    required CancelarReservaUseCase cancelarReservaUseCase,
  })  : _procesarPago = procesarPagoUseCase,
        _cancelarReserva = cancelarReservaUseCase;

  PagoStatus _status = PagoStatus.idle;
  String? _errorMessage;
  PagoEntity? _pago;

  PagoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  PagoEntity? get pago => _pago;
  bool get isProcesando => _status == PagoStatus.procesando;

  Future<bool> pagar({
    required ReservaEntity reserva,
    required String numeroTarjeta,
    required String expiracion,
    required String cvc,
  }) async {
    _status = PagoStatus.procesando;
    _errorMessage = null;
    notifyListeners();

    final result = await _procesarPago(
      reserva: reserva,
      numeroTarjeta: numeroTarjeta,
      expiracion: expiracion,
      cvc: cvc,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = PagoStatus.error;
        notifyListeners();
        return false;
      },
      (pago) {
        _pago = pago;
        _status = PagoStatus.exito;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> cancelar(ReservaEntity reserva) async {
    await _cancelarReserva(reserva);
  }
}
