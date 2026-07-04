import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/domain/entities/pago_entity.dart';
import 'package:pry_final_parqueadero/domain/entities/reserva_entity.dart';
import 'package:pry_final_parqueadero/domain/repositories/pago_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/pagos/procesar_pago_usecase.dart';

class MockPagoRepository extends Mock implements PagoRepository {}

ReservaEntity _reserva({double montoTotal = 3.0}) {
  final inicio = DateTime(2026, 7, 1, 10);
  return ReservaEntity(
    id: 'r1',
    usuarioId: 'u1',
    espacioId: 'e1',
    parqueaderoId: 'p1',
    placa: 'PBA1234',
    fechaInicio: inicio,
    fechaFin: inicio.add(const Duration(hours: 2)),
    montoTotal: montoTotal,
    estado: EstadoReserva.pendiente,
    limiteCheckIn: inicio.add(const Duration(minutes: 10)),
    checkInRealizado: false,
  );
}

PagoEntity _pagoFallback() => PagoEntity(
      id: '',
      reservaId: 'r1',
      usuarioId: 'u1',
      monto: 3,
      ultimos4: '0000',
      estado: EstadoPago.fallido,
      fecha: DateTime(2026, 7, 1),
    );

void main() {
  late ProcesarPagoUseCase sut;
  late MockPagoRepository mockRepo;

  setUpAll(() => registerFallbackValue(_pagoFallback()));
  setUp(() {
    mockRepo = MockPagoRepository();
    sut = ProcesarPagoUseCase(mockRepo);
  });

  test('tarjeta de éxito → pago exitoso y devuelve Right', () async {
    PagoEntity? capturado;
    when(() => mockRepo.registrarPago(any())).thenAnswer((inv) async {
      capturado = inv.positionalArguments.first as PagoEntity;
      return Right(capturado!);
    });

    final result = await sut(
      reserva: _reserva(),
      numeroTarjeta: '4242 4242 4242 4242',
      expiracion: '12/30',
      cvc: '123',
    );

    expect(result.isRight(), isTrue);
    expect(capturado!.estado, EstadoPago.exitoso);
    verify(() => mockRepo.registrarPago(any())).called(1);
  });

  test('tarjeta declinada → ValidationFailure y registra pago fallido', () async {
    PagoEntity? capturado;
    when(() => mockRepo.registrarPago(any())).thenAnswer((inv) async {
      capturado = inv.positionalArguments.first as PagoEntity;
      return Right(capturado!);
    });

    final result = await sut(
      reserva: _reserva(),
      numeroTarjeta: '4000 0000 0000 0002',
      expiracion: '12/30',
      cvc: '123',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
        (f) => expect(f, isA<ValidationFailure>()), (_) => fail('esperaba Failure'));
    expect(capturado!.estado, EstadoPago.fallido);
    verify(() => mockRepo.registrarPago(any())).called(1);
  });

  test('tarjeta con formato inválido → ValidationFailure sin tocar el repo',
      () async {
    final result = await sut(
      reserva: _reserva(),
      numeroTarjeta: '4242',
      expiracion: '12/30',
      cvc: '123',
    );

    expect(result.isLeft(), isTrue);
    verifyNever(() => mockRepo.registrarPago(any()));
  });

  test('el monto del pago == reserva.montoTotal', () async {
    PagoEntity? capturado;
    when(() => mockRepo.registrarPago(any())).thenAnswer((inv) async {
      capturado = inv.positionalArguments.first as PagoEntity;
      return Right(capturado!);
    });

    await sut(
      reserva: _reserva(montoTotal: 7.5),
      numeroTarjeta: '4242424242424242',
      expiracion: '12/30',
      cvc: '123',
    );

    expect(capturado!.monto, 7.5);
    expect(capturado!.ultimos4, '4242');
  });
}
