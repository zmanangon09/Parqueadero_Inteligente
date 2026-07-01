import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/domain/entities/espacio_entity.dart';
import 'package:pry_final_parqueadero/domain/repositories/espacio_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/espacios/watch_espacios_usecase.dart';

class MockEspacioRepository extends Mock implements EspacioRepository {}

void main() {
  late WatchEspaciosUseCase sut;
  late MockEspacioRepository mockRepo;

  const tEspacios = [
    EspacioEntity(
      id: 'e1',
      parqueaderoId: 'p1',
      numero: 1,
      estado: EstadoEspacio.libre,
      tipo: TipoEspacio.normal,
    ),
    EspacioEntity(
      id: 'e2',
      parqueaderoId: 'p1',
      numero: 2,
      estado: EstadoEspacio.ocupado,
      tipo: TipoEspacio.normal,
    ),
  ];

  setUp(() {
    mockRepo = MockEspacioRepository();
    sut = WatchEspaciosUseCase(mockRepo);
  });

  test('emite lista de espacios cuando el repositorio emite datos', () {
    when(() => mockRepo.watchEspaciosByParqueadero('p1'))
        .thenAnswer((_) => Stream.value(const Right(tEspacios)));

    expect(
      sut('p1'),
      emits(const Right<Failure, List<EspacioEntity>>(tEspacios)),
    );
  });

  test('emite ServerFailure cuando el repositorio emite error', () {
    when(() => mockRepo.watchEspaciosByParqueadero('p1')).thenAnswer(
      (_) => Stream.value(
        const Left(ServerFailure('Error de conexión')),
      ),
    );

    expect(
      sut('p1'),
      emits(const Left<Failure, List<EspacioEntity>>(
        ServerFailure('Error de conexión'),
      )),
    );
  });

  test('emite múltiples eventos cuando el stream actualiza', () {
    const updated = [
      EspacioEntity(
        id: 'e1',
        parqueaderoId: 'p1',
        numero: 1,
        estado: EstadoEspacio.ocupado,
        tipo: TipoEspacio.normal,
      ),
    ];

    when(() => mockRepo.watchEspaciosByParqueadero('p1')).thenAnswer(
      (_) => Stream.fromIterable([
        const Right(tEspacios),
        const Right(updated),
      ]),
    );

    expect(
      sut('p1'),
      emitsInOrder([
        const Right<Failure, List<EspacioEntity>>(tEspacios),
        const Right<Failure, List<EspacioEntity>>(updated),
      ]),
    );
  });
}
