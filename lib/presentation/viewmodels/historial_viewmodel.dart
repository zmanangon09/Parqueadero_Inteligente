import 'package:flutter/foundation.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/repositories/parqueadero_repository.dart';
import '../../domain/usecases/reservas/cancelar_reserva_usecase.dart';
import '../../domain/usecases/reservas/get_reservas_usuario_usecase.dart';
import '../../domain/usecases/reservas/liberar_reservas_expiradas_usecase.dart';

class HistorialViewModel extends ChangeNotifier {
  final GetReservasUsuarioUseCase _getReservasUseCase;
  final LiberarReservasExpiradasUseCase _liberarExpiradasUseCase;
  final CancelarReservaUseCase _cancelarReservaUseCase;
  final ParqueaderoRepository _parqueaderoRepo;

  HistorialViewModel({
    required GetReservasUsuarioUseCase getReservasUseCase,
    required LiberarReservasExpiradasUseCase liberarExpiradasUseCase,
    required CancelarReservaUseCase cancelarReservaUseCase,
    required ParqueaderoRepository parqueaderoRepo,
  })  : _getReservasUseCase = getReservasUseCase,
        _liberarExpiradasUseCase = liberarExpiradasUseCase,
        _cancelarReservaUseCase = cancelarReservaUseCase,
        _parqueaderoRepo = parqueaderoRepo;

  bool _isLoading = false;
  String? _errorMessage;
  List<ReservaEntity> _reservas = [];
  Map<String, String> _parkingNames = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String> get parkingNames => _parkingNames;

  List<ReservaEntity> get activas => _reservas
      .where((r) =>
          r.estado == EstadoReserva.activa ||
          r.estado == EstadoReserva.pendiente)
      .toList();

  List<ReservaEntity> get pasadas => _reservas
      .where((r) =>
          r.estado == EstadoReserva.completada ||
          r.estado == EstadoReserva.cancelada)
      .toList();

  Future<void> init(String usuarioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Barrido de no-shows antes de mostrar: las reservas vencidas sin
    // check-in pasan a canceladas y sus espacios quedan libres.
    await _liberarExpiradasUseCase();

    final nombresRes =
        await _parqueaderoRepo.getParqueaderosCercanos(-0.1807, -78.4678, 99999);
    nombresRes.fold(
      (_) {},
      (list) => _parkingNames = {for (final p in list) p.id: p.nombre},
    );

    final result = await _getReservasUseCase(usuarioId);
    result.fold(
      (f) => _errorMessage = f.message,
      (list) => _reservas = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Cancela una reserva propia y recarga. Devuelve mensaje de error o `null`.
  Future<String?> cancelar(ReservaEntity reserva) async {
    final res = await _cancelarReservaUseCase(reserva);
    final error = res.fold((f) => f.message, (_) => null);
    if (error == null) await init(reserva.usuarioId);
    return error;
  }
}
