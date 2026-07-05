import 'package:flutter/foundation.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/parqueadero_repository.dart';
import '../../domain/repositories/reserva_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final ParqueaderoRepository _parkingRepo;
  final ReservaRepository _reservaRepo;

  AdminDashboardViewModel({
    required AuthRepository authRepo,
    required ParqueaderoRepository parkingRepo,
    required ReservaRepository reservaRepo,
  })  : _authRepo = authRepo,
        _parkingRepo = parkingRepo,
        _reservaRepo = reservaRepo;

  bool _isLoading = false;
  String? _errorMessage;
  int _totalUsers = 0;
  int _totalParkings = 0;
  List<ReservaEntity> _reservas = [];
  Map<String, String> _userNames = {};
  Map<String, String> _parkingNames = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalUsers => _totalUsers;
  int get totalParkings => _totalParkings;
  List<ReservaEntity> get reservas => _reservas;
  Map<String, String> get userNames => _userNames;
  Map<String, String> get parkingNames => _parkingNames;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Obtener conteo de usuarios y lista de usuarios para mapear nombres
      final usersCountRes = await _authRepo.getUsersCount();
      final usersRes = await _authRepo.getAllUsers();
      
      usersCountRes.fold(
        (f) => _errorMessage = f.message,
        (count) => _totalUsers = count,
      );

      usersRes.fold(
        (f) => _errorMessage = f.message,
        (users) {
          _userNames = {for (var u in users) u.uid: u.nombre};
        },
      );

      // 2. Obtener conteo de parqueaderos y lista de parqueaderos para mapear nombres
      final parkingsCountRes = await _parkingRepo.getParqueaderosCount();
      final parkingsRes = await _parkingRepo.getParqueaderosCercanos(-0.1807, -78.4678, 99999); // Cargar todos sin restricción
      
      parkingsCountRes.fold(
        (f) => _errorMessage = f.message,
        (count) => _totalParkings = count,
      );

      parkingsRes.fold(
        (f) => _errorMessage = f.message,
        (parkings) {
          _parkingNames = {for (var p in parkings) p.id: p.nombre};
        },
      );

      // 3. Obtener reservas
      final reservasRes = await _reservaRepo.getAllReservas();
      reservasRes.fold(
        (f) => _errorMessage = f.message,
        (list) {
          _reservas = list;
          // Ordenar reservas por fecha de inicio descendente (más recientes primero)
          _reservas.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
        },
      );

    } catch (e) {
      _errorMessage = 'Error inesperado al cargar estadísticas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => init();

  /// Libera los espacios del parqueadero y recarga el dashboard.
  /// Devuelve `null` si tuvo éxito, o el mensaje de error.
  Future<String?> liberarEspacios(String parqueaderoId) async {
    final res = await _parkingRepo.liberarEspacios(parqueaderoId);
    final error = res.fold((f) => f.message, (_) => null);
    if (error == null) await refresh();
    return error;
  }
}
