import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:pry_final_parqueadero/domain/repositories/auth_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/auth/login_usecase.dart';
import 'package:pry_final_parqueadero/domain/entities/user_entity.dart';
import 'package:pry_final_parqueadero/core/errors/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase sut;
  late MockAuthRepository mockRepo;

  final tUser = UserEntity(
    uid: 'uid-test-1',
    nombre: 'Test User',
    email: 'test@test.com',
    rol: UserRole.cliente,
    telefono: '3001234567',
    fechaRegistro: DateTime(2026),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    sut = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('retorna UserEntity con credenciales correctas', () async {
      when(() => mockRepo.login(email: 'test@test.com', password: '123456'))
          .thenAnswer((_) async => Right(tUser));

      final result = await sut(email: 'test@test.com', password: '123456');

      expect(result, Right(tUser));
      verify(() =>
              mockRepo.login(email: 'test@test.com', password: '123456'))
          .called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('retorna AuthFailure con credenciales inválidas', () async {
      when(() => mockRepo.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer(
              (_) async => const Left(AuthFailure('Contraseña incorrecta.')));

      final result = await sut(email: 'bad@test.com', password: 'wrong');

      expect(result, const Left(AuthFailure('Contraseña incorrecta.')));
    });

    test('retorna AuthFailure cuando el correo no existe', () async {
      when(() => mockRepo.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async =>
              const Left(AuthFailure('No existe una cuenta con ese correo.')));

      final result =
          await sut(email: 'noexiste@test.com', password: '123456');

      expect(result,
          const Left(AuthFailure('No existe una cuenta con ese correo.')));
    });
  });
}
