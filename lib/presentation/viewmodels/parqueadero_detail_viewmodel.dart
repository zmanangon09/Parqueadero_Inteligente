import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/espacio_entity.dart';
import '../../domain/entities/parqueadero_entity.dart';
import '../../domain/usecases/espacios/watch_espacios_usecase.dart';
import '../../domain/usecases/parking/get_parqueadero_by_id_usecase.dart';

enum DetailStatus { idle, loading, loaded, error }

class ParqueaderoDetailViewModel extends ChangeNotifier {
  final GetParqueaderoByIdUseCase _getParqueadero;
  final WatchEspaciosUseCase _watchEspacios;

  DetailStatus _status = DetailStatus.idle;
  ParqueaderoEntity? _parqueadero;
  List<EspacioEntity> _espacios = [];
  String? _errorMessage;
  StreamSubscription<dynamic>? _espaciosSub;

  ParqueaderoDetailViewModel({
    required GetParqueaderoByIdUseCase getParqueaderoByIdUseCase,
    required WatchEspaciosUseCase watchEspaciosUseCase,
  })  : _getParqueadero = getParqueaderoByIdUseCase,
        _watchEspacios = watchEspaciosUseCase;

  DetailStatus get status => _status;
  ParqueaderoEntity? get parqueadero => _parqueadero;
  List<EspacioEntity> get espacios => _espacios;
  String? get errorMessage => _errorMessage;

  int get espaciosLibres =>
      _espacios.where((e) => e.estado == EstadoEspacio.libre).length;
  int get espaciosOcupados =>
      _espacios.where((e) => e.estado == EstadoEspacio.ocupado).length;
  int get espaciosReservados =>
      _espacios.where((e) => e.estado == EstadoEspacio.reservado).length;

  Future<void> init(String parqueaderoId) async {
    _status = DetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getParqueadero(parqueaderoId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = DetailStatus.error;
        notifyListeners();
      },
      (parqueadero) {
        _parqueadero = parqueadero;
        _status = DetailStatus.loaded;
        notifyListeners();
        _subscribeEspacios(parqueaderoId);
      },
    );
  }

  void _subscribeEspacios(String parqueaderoId) {
    _espaciosSub?.cancel();
    _espaciosSub = _watchEspacios(parqueaderoId).listen((result) {
      result.fold(
        (failure) => _errorMessage = failure.message,
        (list) => _espacios = list,
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _espaciosSub?.cancel();
    super.dispose();
  }
}
