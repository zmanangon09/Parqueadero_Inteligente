import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> authStateChanges();

  Future<Either<Failure, int>> getUsersCount();
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  /// Reemplaza la lista de placas del usuario y devuelve el usuario actualizado.
  Future<Either<Failure, UserEntity>> updateVehiculos(
      String uid, List<String> vehiculos);

  /// Sube la foto de perfil a Storage, guarda su URL y devuelve el usuario
  /// actualizado.
  Future<Either<Failure, UserEntity>> updateFotoPerfil(
      String uid, String filePath);
}
