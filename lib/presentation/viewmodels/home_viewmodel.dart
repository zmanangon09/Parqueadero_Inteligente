import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/parqueadero_entity.dart';
import '../../domain/usecases/location/get_current_location_usecase.dart';
import '../../domain/usecases/parking/get_parqueaderos_cercanos_usecase.dart';

enum HomeStatus { idle, loadingLocation, loadingParking, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final GetCurrentLocationUseCase _getLocation;
  final GetParqueaderosCercanosUseCase _getParqueaderos;

  HomeStatus _status = HomeStatus.idle;
  LatLng _currentPosition = const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  List<ParqueaderoEntity> _parqueaderos = [];
  String? _errorMessage;
  ParqueaderoEntity? _selectedParqueadero;

  HomeViewModel({
    required GetCurrentLocationUseCase getLocationUseCase,
    required GetParqueaderosCercanosUseCase getParqueaderosUseCase,
  })  : _getLocation = getLocationUseCase,
        _getParqueaderos = getParqueaderosUseCase;

  HomeStatus get status => _status;
  LatLng get currentPosition => _currentPosition;
  List<ParqueaderoEntity> get parqueaderos => _parqueaderos;
  String? get errorMessage => _errorMessage;
  ParqueaderoEntity? get selectedParqueadero => _selectedParqueadero;

  Future<void> init() async {
    _errorMessage = null;
    _status = HomeStatus.loadingLocation;
    notifyListeners();

    final locationResult = await _getLocation();
    locationResult.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = HomeStatus.error;
        notifyListeners();
      },
      (pos) async {
        _currentPosition = LatLng(pos.$1, pos.$2);
        _status = HomeStatus.loadingParking;
        notifyListeners();
        await _loadParqueaderos();
      },
    );
  }

  Future<void> refresh() async {
    _selectedParqueadero = null;
    await init();
  }

  void selectParqueadero(ParqueaderoEntity p) {
    _selectedParqueadero = p;
    notifyListeners();
  }

  void clearSelection() {
    _selectedParqueadero = null;
    notifyListeners();
  }

  Future<void> _loadParqueaderos() async {
    final result = await _getParqueaderos(
      GetParqueaderosCercanosParams(
        lat: _currentPosition.latitude,
        lng: _currentPosition.longitude,
      ),
    );
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = HomeStatus.error;
      },
      (list) {
        _parqueaderos = list;
        _status = HomeStatus.loaded;
      },
    );
    notifyListeners();
  }
}
