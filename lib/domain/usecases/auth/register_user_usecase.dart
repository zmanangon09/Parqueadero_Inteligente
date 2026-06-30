import 'package:dartz/dartz.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;
  const RegisterUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  }) =>
      _repository.register(
        email: email,
        password: password,
        nombre: nombre,
        telefono: telefono,
      );
}
