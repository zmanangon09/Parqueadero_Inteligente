import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateFotoPerfilUseCase {
  final AuthRepository _repo;
  const UpdateFotoPerfilUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call(String uid, String filePath) =>
      _repo.updateFotoPerfil(uid, filePath);
}
