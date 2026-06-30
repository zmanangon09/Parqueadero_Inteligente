import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:pry_final_parqueadero/domain/repositories/auth_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/auth/login_usecase.dart';
import 'package:pry_final_parqueadero/domain/usecases/auth/register_user_usecase.dart';
import 'package:pry_final_parqueadero/domain/usecases/auth/logout_usecase.dart';
import 'package:pry_final_parqueadero/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pry_final_parqueadero/domain/entities/user_entity.dart';
import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/presentation/viewmodels/auth_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthViewModel sut;
  late MockAuthRepository mockRepo;

  final tUser = UserEntity(
    uid: 'uid-vm-test',
    nombre: 'VM User',
    email: 'vm@test.com',
    rol: UserRole.cliente,
    telefono: '3009876543',
    fechaRegistro: DateTime(2026),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    sut = AuthViewModel(
      loginUseCase: LoginUseCase(mockRepo),
      registerUseCase: RegisterUserUseCase(mockRepo),
      logoutUseCase: LogoutUseCase(mockRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(mockRepo),
    );
  });

  group('AuthViewModel.login', () {
    test('status authenticated y currentUser asignado en login exitoso',
        () async {
      when(() =>
              mockRepo.login(email: 'vm@test.com', password: '123456'))
          .thenAnswer((_) async => Right(tUser));

      await sut.login('vm@test.com', '123456');

      expect(sut.status, AuthStatus.authenticated);
      expect(sut.currentUser, tUser);
      expect(sut.errorMessage, isNull);
    });

    test('status error y errorMessage asignado con credenciales inválidas',
        () async {
      when(() => mockRepo.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async =>
              const Left(AuthFailure('Contraseña incorrecta.')));

      await sut.login('bad@test.com', 'wrong');

      expect(sut.status, AuthStatus.error);
      expect(sut.errorMessage, 'Contraseña incorrecta.');
      expect(sut.currentUser, isNull);
    });

    test('status es loading durante la operación', () async {
      bool wasLoading = false;
      when(() => mockRepo.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async {
        wasLoading = sut.status == AuthStatus.loading;
        return Right(tUser);
      });

      await sut.login('vm@test.com', '123456');

      expect(wasLoading, isTrue);
    });
  });

  group('AuthViewModel.logout', () {
    test('status idle y currentUser null tras logout', () async {
      when(() => mockRepo.logout())
          .thenAnswer((_) async => const Right(unit));
      when(() => mockRepo.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async => Right(tUser));
      await sut.login('vm@test.com', '123456');

      await sut.logout();

      expect(sut.status, AuthStatus.idle);
      expect(sut.currentUser, isNull);
    });
  });
}
