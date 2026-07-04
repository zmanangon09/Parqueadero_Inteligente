import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/local/location_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/espacio_remote_datasource.dart';
import '../../data/datasources/remote/parqueadero_remote_datasource.dart';
import '../../data/datasources/remote/pago_remote_datasource.dart';
import '../../data/datasources/remote/reserva_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/espacio_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/pago_repository_impl.dart';
import '../../data/repositories/parqueadero_repository_impl.dart';
import '../../data/repositories/reserva_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/espacio_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/pago_repository.dart';
import '../../domain/repositories/parqueadero_repository.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_user_usecase.dart';
import '../../domain/usecases/espacios/watch_espacios_usecase.dart';
import '../../domain/usecases/location/get_current_location_usecase.dart';
import '../../domain/usecases/parking/get_parqueadero_by_id_usecase.dart';
import '../../domain/usecases/parking/get_parqueaderos_cercanos_usecase.dart';
import '../../domain/usecases/parking/save_parqueadero_usecase.dart';
import '../../domain/usecases/pagos/procesar_pago_usecase.dart';
import '../../domain/usecases/reservas/cancelar_reserva_usecase.dart';
import '../../domain/usecases/reservas/crear_reserva_usecase.dart';
import '../services/detector_service.dart';
import '../../presentation/viewmodels/add_parqueadero_viewmodel.dart';
import '../../presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/pago_viewmodel.dart';
import '../../presentation/viewmodels/parqueadero_detail_viewmodel.dart';
import '../../presentation/viewmodels/reserva_viewmodel.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Datasources — Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(sl()));

  // Datasources — Location, Parking & Espacios
  sl.registerLazySingleton<LocationLocalDatasource>(
      () => LocationLocalDatasourceImpl());
  sl.registerLazySingleton<ParqueaderoRemoteDatasource>(
      () => ParqueaderoRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<EspacioRemoteDatasource>(
      () => EspacioRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<ReservaRemoteDatasource>(
      () => ReservaRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<PagoRemoteDatasource>(
      () => PagoRemoteDatasourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton<ParqueaderoRepository>(
      () => ParqueaderoRepositoryImpl(sl()));
  sl.registerLazySingleton<EspacioRepository>(
      () => EspacioRepositoryImpl(sl()));
  sl.registerLazySingleton<ReservaRepository>(
      () => ReservaRepositoryImpl(sl()));
  sl.registerLazySingleton<PagoRepository>(() => PagoRepositoryImpl(sl()));

  // Use Cases — Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Use Cases — Home & Detail
  sl.registerLazySingleton(() => GetCurrentLocationUseCase(sl()));
  sl.registerLazySingleton(() => GetParqueaderosCercanosUseCase(sl()));
  sl.registerLazySingleton(() => GetParqueaderoByIdUseCase(sl()));
  sl.registerLazySingleton(() => WatchEspaciosUseCase(sl()));
  sl.registerLazySingleton(() => SaveParqueaderoUseCase(sl()));

  // Services
  sl.registerLazySingleton<SpaceDetectorService>(() => SpaceDetectorService());

  // Use Cases — Reserva & Pago
  sl.registerLazySingleton(() => CrearReservaUseCase(sl()));
  sl.registerLazySingleton(() => CancelarReservaUseCase(sl()));
  sl.registerLazySingleton(() => ProcesarPagoUseCase(sl()));

  // ViewModels
  sl.registerFactory(() => AuthViewModel(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));
  sl.registerFactory(() => HomeViewModel(
        getLocationUseCase: sl(),
        getParqueaderosUseCase: sl(),
      ));
  sl.registerFactory(() => ParqueaderoDetailViewModel(
        getParqueaderoByIdUseCase: sl(),
        watchEspaciosUseCase: sl(),
      ));
  sl.registerFactory(() => ReservaViewModel(crearReservaUseCase: sl()));
  sl.registerFactory(() => PagoViewModel(
        procesarPagoUseCase: sl(),
        cancelarReservaUseCase: sl(),
      ));
  sl.registerFactory(() => AdminDashboardViewModel(
        authRepo: sl(),
        parkingRepo: sl(),
        reservaRepo: sl(),
      ));
  sl.registerFactory(() => AddParqueaderoViewModel(
        saveParqueaderoUseCase: sl(),
        detectorService: sl(),
      ));
}
