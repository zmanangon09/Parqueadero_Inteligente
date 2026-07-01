import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/domain/entities/parqueadero_entity.dart';
import 'package:pry_final_parqueadero/domain/repositories/parqueadero_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/parking/get_parqueaderos_cercanos_usecase.dart';

class MockParqueaderoRepository extends Mock implements ParqueaderoRepository {}

void main() {
  late GetParqueaderosCercanosUseCase sut;
  late MockParqueaderoRepository mockRepo;

  // Parqueadero dentro del radio (aprox 1.1 km del origen)
  const tCercano = ParqueaderoEntity(
    id: 'p1',
    nombre: 'Parqueadero Centro',
    direccion: 'Calle 10 # 5-20',
    lat: 4.7010,
    lng: -74.0721,
    capacidadTotal: 50,
    espaciosDisponibles: 10,
    tarifaPorHora: 3000,
    horario: '6am - 10pm',
    adminId: 'admin1',
  );

  // Parqueadero fuera del radio (aprox 50 km)
  const tLejano = ParqueaderoEntity(
    id: 'p2',
    nombre: 'Parqueadero Lejano',
    direccion: 'Av. 80 # 100-200',
    lat: 5.1000,
    lng: -74.0721,
    capacidadTotal: 30,
    espaciosDisponibles: 5,
    tarifaPorHora: 2500,
    horario: '7am - 9pm',
    adminId: 'admin2',
  );

  const tParams = GetParqueaderosCercanosParams(
    lat: 4.7110,
    lng: -74.0721,
    radiusKm: 5.0,
  );

  setUp(() {
    mockRepo = MockParqueaderoRepository();
    sut = GetParqueaderosCercanosUseCase(mockRepo);
  });

  test('retorna lista con parqueaderos dentro del radio', () async {
    when(() => mockRepo.getParqueaderosCercanos(any(), any(), any()))
        .thenAnswer((_) async => const Right([tCercano]));

    final result = await sut(tParams);

    expect(result, const Right([tCercano]));
    verify(() => mockRepo.getParqueaderosCercanos(4.7110, -74.0721, 5.0))
        .called(1);
  });

  test('retorna lista vacía si ningún parqueadero está en el radio', () async {
    when(() => mockRepo.getParqueaderosCercanos(any(), any(), any()))
        .thenAnswer((_) async => const Right([]));

    final result = await sut(tParams);

    expect(result, const Right(<ParqueaderoEntity>[]));
  });

  test('retorna ServerFailure si el repositorio lanza error', () async {
    when(() => mockRepo.getParqueaderosCercanos(any(), any(), any()))
        .thenAnswer(
            (_) async => const Left(ServerFailure('Error de conexión')));

    final result = await sut(tParams);

    expect(result, const Left(ServerFailure('Error de conexión')));
  });
}
