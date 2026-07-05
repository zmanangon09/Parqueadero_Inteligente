import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pry_final_parqueadero/core/errors/failures.dart';
import 'package:pry_final_parqueadero/domain/entities/reserva_entity.dart';
import 'package:pry_final_parqueadero/domain/repositories/reserva_repository.dart';
import 'package:pry_final_parqueadero/domain/usecases/reservas/procesar_qr_usecase.dart';

class MockReservaRepository extends Mock implements ReservaRepository {}

void main() {
  late MockReservaRepository repo;
  late ProcesarQrUseCase useCase;

  setUp(() {
    repo = MockReservaRepository();
    useCase = ProcesarQrUseCase(repo);
  });

  ReservaEntity reserva({
    required EstadoReserva estado,
    bool checkInRealizado = false,
    DateTime? limiteCheckIn,
  }) =>
      ReservaEntity(
        id: 'r1',
        usuarioId: 'u1',
        espacioId: 'e1',
        parqueaderoId: 'p1',
        placa: 'PBA1234',
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now().add(const Duration(hours: 2)),
        montoTotal: 3.0,
        estado: estado,
        limiteCheckIn:
            limiteCheckIn ?? DateTime.now().add(const Duration(minutes: 10)),
        checkInRealizado: checkInRealizado,
        qrCode: 'r1',
      );

  setUpAll(() {
    registerFallbackValue(reserva(estado: EstadoReserva.activa));
  });

  test('reserva activa sin check-in dentro de la ventana → check-in', () async {
    final r = reserva(estado: EstadoReserva.activa);
    when(() => repo.getReservaByQr('r1')).thenAnswer((_) async => Right(r));
    when(() => repo.checkIn(r)).thenAnswer((_) async => const Right(null));

    final result = await useCase('r1');

    expect(result.isRight(), true);
    result.fold((_) {}, (res) => expect(res.accion, QrAccion.checkIn));
    verify(() => repo.checkIn(r)).called(1);
    verifyNever(() => repo.checkOut(any()));
  });

  test('reserva activa con ventana vencida → no-show cancela y libera',
      () async {
    final r = reserva(
      estado: EstadoReserva.activa,
      limiteCheckIn: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    when(() => repo.getReservaByQr('r1')).thenAnswer((_) async => Right(r));
    when(() => repo.cancelarReserva(r))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase('r1');

    expect(result.isRight(), true);
    result.fold((_) {}, (res) => expect(res.accion, QrAccion.noShow));
    verify(() => repo.cancelarReserva(r)).called(1);
    verifyNever(() => repo.checkIn(any()));
  });

  test('reserva activa con check-in hecho → check-out completa', () async {
    final r = reserva(estado: EstadoReserva.activa, checkInRealizado: true);
    when(() => repo.getReservaByQr('r1')).thenAnswer((_) async => Right(r));
    when(() => repo.checkOut(r)).thenAnswer((_) async => const Right(null));

    final result = await useCase('r1');

    expect(result.isRight(), true);
    result.fold((_) {}, (res) => expect(res.accion, QrAccion.checkOut));
    verify(() => repo.checkOut(r)).called(1);
  });

  test('reserva pendiente de pago → ValidationFailure', () async {
    final r = reserva(estado: EstadoReserva.pendiente);
    when(() => repo.getReservaByQr('r1')).thenAnswer((_) async => Right(r));

    final result = await useCase('r1');

    expect(result.isLeft(), true);
    result.fold((f) => expect(f, isA<ValidationFailure>()), (_) {});
    verifyNever(() => repo.checkIn(any()));
  });

  test('QR desconocido → propaga el failure del repositorio', () async {
    when(() => repo.getReservaByQr('xxx')).thenAnswer((_) async =>
        const Left(ValidationFailure('El código QR no corresponde a una reserva.')));

    final result = await useCase('xxx');

    expect(result.isLeft(), true);
  });
}
