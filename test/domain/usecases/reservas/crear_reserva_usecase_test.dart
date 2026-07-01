import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/domain/entities/reserva_entity.dart';
import 'package:pry_final_parqueadero/domain/repositories/reserva_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/reservas/crear_reserva_usecase.dart';

class MockReservaRepository extends Mock implements ReservaRepository {}

ReservaEntity _reservaFixture({
  String id = 'r1',
  double montoTotal = 3.0,
  EstadoReserva estado = EstadoReserva.activa,
}) {
  final inicio = DateTime(2026, 7, 1, 10);
  return ReservaEntity(
    id: id,
    usuarioId: 'u1',
    espacioId: 'e1',
    parqueaderoId: 'p1',
    placa: 'PBA1234',
    fechaInicio: inicio,
    fechaFin: inicio.add(const Duration(hours: 2)),
    montoTotal: montoTotal,
    estado: estado,
    limiteCheckIn: inicio.add(const Duration(minutes: 10)),
    checkInRealizado: false,
  );
}

void main() {
  late CrearReservaUseCase sut;
  late MockReservaRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_reservaFixture());
  });

  setUp(() {
    mockRepo = MockReservaRepository();
    sut = CrearReservaUseCase(mockRepo);
  });

  Future<Either<Failure, ReservaEntity>> callSut({
    String placa = 'PBA1234',
    int duracionHoras = 2,
    double tarifaPorHora = 1.5,
  }) =>
      sut(
        usuarioId: 'u1',
        espacioId: 'e1',
        parqueaderoId: 'p1',
        placa: placa,
        duracionHoras: duracionHoras,
        tarifaPorHora: tarifaPorHora,
      );

  test('reserva un espacio disponible y devuelve la reserva creada', () async {
    final tReserva = _reservaFixture();
    when(() => mockRepo.crearReserva(any()))
        .thenAnswer((_) async => Right(tReserva));

    final result = await callSut();

    expect(result, Right<Failure, ReservaEntity>(tReserva));
    verify(() => mockRepo.crearReserva(any())).called(1);
  });

  test('rechaza la reserva cuando el espacio ya está ocupado', () async {
    const failure = ValidationFailure('El espacio ya no está disponible');
    when(() => mockRepo.crearReserva(any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await callSut();

    expect(result, const Left<Failure, ReservaEntity>(failure));
  });

  test('rechaza con ValidationFailure si la placa es inválida sin llamar al repo',
      () async {
    final result = await callSut(placa: '');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('esperaba un Failure'),
    );
    verifyNever(() => mockRepo.crearReserva(any()));
  });

  test('calcula montoTotal = duracionHoras × tarifaPorHora', () async {
    ReservaEntity? capturada;
    when(() => mockRepo.crearReserva(any())).thenAnswer((invocation) async {
      capturada = invocation.positionalArguments.first as ReservaEntity;
      return Right(capturada!);
    });

    await callSut(duracionHoras: 3, tarifaPorHora: 2.0);

    expect(capturada!.montoTotal, 6.0);
  });

  test('construye la reserva con estado activa y checkInRealizado en false',
      () async {
    ReservaEntity? capturada;
    when(() => mockRepo.crearReserva(any())).thenAnswer((invocation) async {
      capturada = invocation.positionalArguments.first as ReservaEntity;
      return Right(capturada!);
    });

    await callSut();

    expect(capturada!.estado, EstadoReserva.activa);
    expect(capturada!.checkInRealizado, isFalse);
    expect(
      capturada!.limiteCheckIn.difference(capturada!.fechaInicio),
      const Duration(minutes: 10),
    );
  });
}
