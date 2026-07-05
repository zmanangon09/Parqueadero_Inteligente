import 'package:flutter/foundation.dart';
import '../../core/services/detector_service.dart';
import '../../domain/entities/espacio_entity.dart';
import '../../domain/usecases/espacios/actualizar_ocupacion_usecase.dart';
import '../../domain/usecases/espacios/get_espacios_parqueadero_usecase.dart';

/// Evaluación de espacios libres con la cámara (panel admin):
/// captura foto → TFLite cuenta vehículos → propuesta de estados → aplicar.
class EvaluarOcupacionViewModel extends ChangeNotifier {
  final GetEspaciosParqueaderoUseCase _getEspaciosUseCase;
  final ActualizarOcupacionUseCase _actualizarOcupacionUseCase;
  final SpaceDetectorService _detectorService;

  EvaluarOcupacionViewModel({
    required GetEspaciosParqueaderoUseCase getEspaciosUseCase,
    required ActualizarOcupacionUseCase actualizarOcupacionUseCase,
    required SpaceDetectorService detectorService,
  })  : _getEspaciosUseCase = getEspaciosUseCase,
        _actualizarOcupacionUseCase = actualizarOcupacionUseCase,
        _detectorService = detectorService;

  String _parqueaderoId = '';
  List<EspacioEntity> _espacios = [];
  String? _fotoPath;
  bool _isLoading = false;
  bool _isDetecting = false;
  bool _isSaving = false;
  int _vehiculosDetectados = 0;
  List<EspacioEntity> _propuesta = [];
  String? _errorMessage;

  List<EspacioEntity> get espacios => _espacios;
  String? get fotoPath => _fotoPath;
  bool get isLoading => _isLoading;
  bool get isDetecting => _isDetecting;
  bool get isSaving => _isSaving;
  int get vehiculosDetectados => _vehiculosDetectados;
  List<EspacioEntity> get propuesta => _propuesta;
  String? get errorMessage => _errorMessage;
  bool get tienePropuesta => _fotoPath != null && !_isDetecting;

  int get propuestaLibres =>
      _propuesta.where((e) => e.estado == EstadoEspacio.libre).length;
  int get propuestaOcupados =>
      _propuesta.where((e) => e.estado == EstadoEspacio.ocupado).length;
  int get propuestaReservados =>
      _propuesta.where((e) => e.estado == EstadoEspacio.reservado).length;

  Future<void> init(String parqueaderoId) async {
    _parqueaderoId = parqueaderoId;
    _isLoading = true;
    _errorMessage = null;
    _fotoPath = null;
    _propuesta = [];
    notifyListeners();

    final result = await _getEspaciosUseCase(parqueaderoId);
    result.fold(
      (f) => _errorMessage = f.message,
      (list) => _espacios = list,
    );
    _isLoading = false;
    notifyListeners();
  }

  /// Corre TFLite sobre la foto capturada y arma la propuesta de estados.
  Future<void> evaluarFoto(String imagePath) async {
    _fotoPath = imagePath;
    _isDetecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detections = await _detectorService.detectVehicles(imagePath);
      _vehiculosDetectados = detections.length;
      _propuesta = ActualizarOcupacionUseCase.sugerirOcupacion(
          _espacios, _vehiculosDetectados);
    } catch (e) {
      _errorMessage = 'Error en la detección: $e';
      _fotoPath = null;
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  /// Aplica la propuesta. Devuelve `true` si se guardó.
  Future<bool> aplicar() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _actualizarOcupacionUseCase(_parqueaderoId, _propuesta);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        _isSaving = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }

  void descartarFoto() {
    _fotoPath = null;
    _propuesta = [];
    _vehiculosDetectados = 0;
    notifyListeners();
  }
}
