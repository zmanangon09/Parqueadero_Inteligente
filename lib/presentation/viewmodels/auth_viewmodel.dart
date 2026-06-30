import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_user_usecase.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUserUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserEntity? _currentUser;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.rol == UserRole.admin;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUserUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  Future<void> login(String email, String password) async {
    _setLoading();
    final result = await _loginUseCase(email: email, password: password);
    result.fold((f) => _setError(f.message), _setAuthenticated);
  }

  Future<void> register(
      String email, String password, String nombre, String telefono) async {
    _setLoading();
    final result = await _registerUseCase(
        email: email, password: password, nombre: nombre, telefono: telefono);
    result.fold((f) => _setError(f.message), _setAuthenticated);
  }

  Future<void> logout() async {
    _setLoading();
    await _logoutUseCase();
    _status = AuthStatus.idle;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    _setLoading();
    final result = await _getCurrentUserUseCase();
    result.fold(
      (_) {
        _status = AuthStatus.idle;
        notifyListeners();
      },
      (user) {
        if (user != null) {
          _setAuthenticated(user);
        } else {
          _status = AuthStatus.idle;
          notifyListeners();
        }
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setAuthenticated(UserEntity user) {
    _status = AuthStatus.authenticated;
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }
}
