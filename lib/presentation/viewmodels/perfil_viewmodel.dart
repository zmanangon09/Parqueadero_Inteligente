import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/perfil/update_foto_perfil_usecase.dart';
import '../../domain/usecases/perfil/update_vehiculos_usecase.dart';

class PerfilViewModel extends ChangeNotifier {
  final UpdateVehiculosUseCase _updateVehiculosUseCase;
  final UpdateFotoPerfilUseCase _updateFotoPerfilUseCase;

  PerfilViewModel({
    required UpdateVehiculosUseCase updateVehiculosUseCase,
    required UpdateFotoPerfilUseCase updateFotoPerfilUseCase,
  })  : _updateVehiculosUseCase = updateVehiculosUseCase,
        _updateFotoPerfilUseCase = updateFotoPerfilUseCase;

  bool _isSaving = false;
  String? _errorMessage;
  UserEntity? _updatedUser;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Usuario actualizado tras la última operación exitosa (para refrescar
  /// el AuthViewModel sin releer la sesión).
  UserEntity? get updatedUser => _updatedUser;

  Future<bool> agregarPlaca(UserEntity user, String placa) =>
      _updateVehiculos(user, [...user.vehiculos, placa]);

  Future<bool> eliminarPlaca(UserEntity user, String placa) =>
      _updateVehiculos(
          user, user.vehiculos.where((p) => p != placa).toList());

  Future<bool> _updateVehiculos(UserEntity user, List<String> placas) async {
    _start();
    final result = await _updateVehiculosUseCase(user.uid, placas);
    return _finish(result.fold((f) {
      _errorMessage = f.message;
      return null;
    }, (u) => u));
  }

  Future<bool> cambiarFoto(UserEntity user, String filePath) async {
    _start();
    final result = await _updateFotoPerfilUseCase(user.uid, filePath);
    return _finish(result.fold((f) {
      _errorMessage = f.message;
      return null;
    }, (u) => u));
  }

  void _start() {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
  }

  bool _finish(UserEntity? user) {
    if (user != null) _updatedUser = user;
    _isSaving = false;
    notifyListeners();
    return user != null;
  }
}
