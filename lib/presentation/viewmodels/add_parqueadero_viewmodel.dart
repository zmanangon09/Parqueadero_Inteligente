import 'package:flutter/foundation.dart';
import '../../core/services/detector_service.dart';
import '../../domain/entities/espacio_entity.dart';
import '../../domain/entities/parqueadero_entity.dart';
import '../../domain/usecases/parking/save_parqueadero_usecase.dart';

class AddParqueaderoViewModel extends ChangeNotifier {
  final SaveParqueaderoUseCase _saveParqueaderoUseCase;
  final SpaceDetectorService _detectorService;

  AddParqueaderoViewModel({
    required SaveParqueaderoUseCase saveParqueaderoUseCase,
    required SpaceDetectorService detectorService,
  })  : _saveParqueaderoUseCase = saveParqueaderoUseCase,
        _detectorService = detectorService;

  // Formulario Básico
  String _nombre = '';
  double _tarifaPorHora = 0.0;
  String _direccion = '';
  double _lat = -0.1807;
  double _lng = -78.4678;

  // Escaneo y Detección
  String? _imagePath;
  bool _isProcessingImage = false;
  List<EspacioEntity> _detectedSpaces = [];

  // Estado general
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get nombre => _nombre;
  double get tarifaPorHora => _tarifaPorHora;
  String get direccion => _direccion;
  double get lat => _lat;
  double get lng => _lng;
  String? get imagePath => _imagePath;
  bool get isProcessingImage => _isProcessingImage;
  List<EspacioEntity> get detectedSpaces => _detectedSpaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters calculados para la revisión
  int get capacidadTotal => _detectedSpaces.length;
  int get espaciosDisponibles =>
      _detectedSpaces.where((e) => e.estado == EstadoEspacio.libre).length;
  int get espaciosOcupados =>
      _detectedSpaces.where((e) => e.estado == EstadoEspacio.ocupado).length;

  void setBasicInfo({
    required String nombre,
    required double tarifaPorHora,
    required String direccion,
    required double lat,
    required double lng,
  }) {
    _nombre = nombre;
    _tarifaPorHora = tarifaPorHora;
    _direccion = direccion;
    _lat = lat;
    _lng = lng;
    notifyListeners();
  }

  Future<void> scanAndDetect(String imagePath) async {
    _imagePath = imagePath;
    _isProcessingImage = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final spaces = await _detectorService.detectSpaces(imagePath);
      _detectedSpaces = spaces;
    } catch (e) {
      _errorMessage = 'Error en la visión artificial: $e';
    } finally {
      _isProcessingImage = false;
      notifyListeners();
    }
  }

  // Modificación manual: alternar estado entre libre y ocupado
  void toggleSpaceEstado(int index) {
    if (index < 0 || index >= _detectedSpaces.length) return;
    
    final space = _detectedSpaces[index];
    final nuevoEstado = space.estado == EstadoEspacio.libre
        ? EstadoEspacio.ocupado
        : EstadoEspacio.libre;

    _detectedSpaces[index] = EspacioEntity(
      id: space.id,
      parqueaderoId: space.parqueaderoId,
      numero: space.numero,
      estado: nuevoEstado,
      tipo: space.tipo,
    );
    notifyListeners();
  }

  // Modificación manual: agregar espacio
  void addSpace() {
    // Buscar el número más alto para sugerir el siguiente consecutivo
    final maxNumero = _detectedSpaces.isEmpty
        ? 0
        : _detectedSpaces.map((e) => e.numero).reduce((a, b) => a > b ? a : b);

    _detectedSpaces.add(
      EspacioEntity(
        id: '',
        parqueaderoId: '',
        numero: maxNumero + 1,
        estado: EstadoEspacio.libre,
        tipo: TipoEspacio.normal,
      ),
    );
    notifyListeners();
  }

  // Modificación manual: eliminar espacio
  void removeSpace(int index) {
    if (index < 0 || index >= _detectedSpaces.length) return;
    _detectedSpaces.removeAt(index);
    notifyListeners();
  }

  // Modificación manual: cambiar tipo de espacio
  void updateSpaceTipo(int index, TipoEspacio tipo) {
    if (index < 0 || index >= _detectedSpaces.length) return;
    
    final space = _detectedSpaces[index];
    _detectedSpaces[index] = EspacioEntity(
      id: space.id,
      parqueaderoId: space.parqueaderoId,
      numero: space.numero,
      estado: space.estado,
      tipo: tipo,
    );
    notifyListeners();
  }

  // Modificación manual: renombrar número del espacio
  void renameSpace(int index, int newNumber) {
    if (index < 0 || index >= _detectedSpaces.length) return;
    
    final space = _detectedSpaces[index];
    _detectedSpaces[index] = EspacioEntity(
      id: space.id,
      parqueaderoId: space.parqueaderoId,
      numero: newNumber,
      estado: space.estado,
      tipo: space.tipo,
    );
    notifyListeners();
  }

  // Modificar capacidad total directamente (agregando o removiendo espacios libres genéricos)
  void setCapacidadTotal(int nuevaCapacidad) {
    if (nuevaCapacidad < 0) return;
    
    if (nuevaCapacidad > _detectedSpaces.length) {
      // Agregar espacios libres
      final diferencia = nuevaCapacidad - _detectedSpaces.length;
      for (int i = 0; i < diferencia; i++) {
        addSpace();
      }
    } else if (nuevaCapacidad < _detectedSpaces.length) {
      // Remover los últimos espacios
      final diferencia = _detectedSpaces.length - nuevaCapacidad;
      for (int i = 0; i < diferencia; i++) {
        _detectedSpaces.removeLast();
      }
      notifyListeners();
    }
  }

  // Limpiar formulario y estados
  void reset() {
    _nombre = '';
    _tarifaPorHora = 0.0;
    _direccion = '';
    _lat = -0.1807;
    _lng = -78.4678;
    _imagePath = null;
    _isProcessingImage = false;
    _detectedSpaces = [];
    _isLoading = false;
    _errorMessage = null;
  }

  // Guardar en Firebase
  Future<bool> saveParqueadero(String adminId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final parqueadero = ParqueaderoEntity(
      id: '', // Se autogenerará en Firebase
      nombre: _nombre,
      direccion: _direccion,
      lat: _lat,
      lng: _lng,
      capacidadTotal: capacidadTotal,
      espaciosDisponibles: espaciosDisponibles,
      tarifaPorHora: _tarifaPorHora,
      horario: '24/7', // Horario estándar predeterminado
      adminId: adminId,
    );

    final result = await _saveParqueaderoUseCase(
      parqueadero: parqueadero,
      espacios: _detectedSpaces,
    );

    return result.fold(
      (f) {
        _errorMessage = f.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        reset();
        return true;
      },
    );
  }
}
