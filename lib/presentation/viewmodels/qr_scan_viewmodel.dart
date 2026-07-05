import 'package:flutter/foundation.dart';
import '../../domain/usecases/reservas/procesar_qr_usecase.dart';

class QrScanViewModel extends ChangeNotifier {
  final ProcesarQrUseCase _procesarQrUseCase;

  QrScanViewModel({required ProcesarQrUseCase procesarQrUseCase})
      : _procesarQrUseCase = procesarQrUseCase;

  bool _isProcessing = false;
  QrResultado? _resultado;
  String? _errorMessage;

  bool get isProcessing => _isProcessing;
  QrResultado? get resultado => _resultado;
  String? get errorMessage => _errorMessage;

  /// Procesa un QR detectado. Devuelve `true` si hubo acción exitosa.
  Future<bool> procesarQr(String qr) async {
    if (_isProcessing) return false;
    _isProcessing = true;
    _resultado = null;
    _errorMessage = null;
    notifyListeners();

    final result = await _procesarQrUseCase(qr);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        _isProcessing = false;
        notifyListeners();
        return false;
      },
      (r) {
        _resultado = r;
        _isProcessing = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Permite volver a escanear tras cerrar el diálogo de resultado.
  void reset() {
    _resultado = null;
    _errorMessage = null;
    notifyListeners();
  }
}
