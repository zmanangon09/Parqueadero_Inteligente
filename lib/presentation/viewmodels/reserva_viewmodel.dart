import 'package:flutter/foundation.dart';

import '../../domain/entities/reserva_entity.dart';
import '../../domain/usecases/reservas/crear_reserva_usecase.dart';

enum ReservaStatus { idle, loading, success, error }

class ReservaViewModel extends ChangeNotifier {
  final CrearReservaUseCase _crearReserva;

  ReservaViewModel({required CrearReservaUseCase crearReservaUseCase})
      : _crearReserva = crearReservaUseCase;

  ReservaStatus _status = ReservaStatus.idle;
  String? _errorMessage;
  ReservaEntity? _reserva;

  ReservaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ReservaEntity? get reserva => _reserva;
  bool get isLoading => _status == ReservaStatus.loading;

  Future<bool> reservar({
    required String usuarioId,
    required String espacioId,
    required String parqueaderoId,
    required String placa,
    required int duracionHoras,
    required double tarifaPorHora,
  }) async {
    _status = ReservaStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _crearReserva(
      usuarioId: usuarioId,
      espacioId: espacioId,
      parqueaderoId: parqueaderoId,
      placa: placa,
      duracionHoras: duracionHoras,
      tarifaPorHora: tarifaPorHora,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = ReservaStatus.error;
        notifyListeners();
        return false;
      },
      (reserva) {
        _reserva = reserva;
        _status = ReservaStatus.success;
        notifyListeners();
        return true;
      },
    );
  }
}
