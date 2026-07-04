# Módulo 5 — Pago (simulado) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Añadir un paso de pago simulado (estilo Stripe test-mode) que pasa la reserva de `pendiente` a `activa` tras un pago exitoso, persistiendo el registro en `pagos/`.

**Architecture:** Clean Architecture + MVVM + Provider, como el resto del proyecto. Dominio: `PagoEntity` + `ProcesarPagoUseCase`. Datos: `PagoModel` + datasource con transacción Firestore (crea pago y, solo si es exitoso, actualiza la reserva a `activa`). Presentación: `PagoView` en ruta dedicada `/pago/:reservaId`, con la `ReservaEntity` pasada por `extra` de GoRouter.

**Tech Stack:** Flutter 3.41, dartz (`Either`), get_it (DI), go_router, provider, cloud_firestore, mocktail (tests).

## Global Constraints

- **Commits sin atribución a Claude:** nunca incluir `Co-Authored-By: Claude` ni ninguna traza de IA. Usar las credenciales normales de git.
- **ViewModels sin acceso directo a Firebase:** solo hablan con use cases.
- **Use cases devuelven `Either<Failure, T>`** (dartz). Errores de validación → `ValidationFailure`; de infraestructura → `ServerFailure`.
- **Simulación determinista por tarjeta:** `4242424242424242` → éxito; cualquier otra con formato válido → declinada (fallido).
- **`flutter analyze` sin errores** y **`flutter test` todo en verde** al cerrar cada tarea con tests.
- Paleta Trust Teal: primario `#0F766E`, oscuro `#134E4A`, fondo `#F0FDFA`, error `#DC2626`.

---

### Task 1: Validadores de tarjeta

**Files:**
- Modify: `lib/core/utils/validators.dart`
- Test: `test/core/utils/validators_tarjeta_test.dart`

**Interfaces:**
- Produces: `Validators.numeroTarjeta(String?)`, `Validators.expiracionTarjeta(String?)`, `Validators.cvc(String?)` — cada uno devuelve `String?` (mensaje de error) o `null` si es válido.

- [ ] **Step 1: Escribir el test que falla**

Crear `test/core/utils/validators_tarjeta_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pry_final_parqueadero/core/utils/validators.dart';

void main() {
  group('numeroTarjeta', () {
    test('acepta 16 dígitos (con o sin espacios)', () {
      expect(Validators.numeroTarjeta('4242424242424242'), isNull);
      expect(Validators.numeroTarjeta('4242 4242 4242 4242'), isNull);
    });
    test('rechaza vacío', () {
      expect(Validators.numeroTarjeta(''), isNotNull);
    });
    test('rechaza longitud incorrecta', () {
      expect(Validators.numeroTarjeta('4242'), isNotNull);
    });
  });

  group('expiracionTarjeta', () {
    test('acepta MM/YY futura', () {
      expect(Validators.expiracionTarjeta('12/30'), isNull);
    });
    test('rechaza formato inválido', () {
      expect(Validators.expiracionTarjeta('1230'), isNotNull);
      expect(Validators.expiracionTarjeta('13/30'), isNotNull);
    });
    test('rechaza tarjeta vencida', () {
      expect(Validators.expiracionTarjeta('01/20'), isNotNull);
    });
  });

  group('cvc', () {
    test('acepta 3 dígitos', () => expect(Validators.cvc('123'), isNull));
    test('rechaza no-3-dígitos', () {
      expect(Validators.cvc('12'), isNotNull);
      expect(Validators.cvc('abcd'), isNotNull);
    });
  });
}
```

- [ ] **Step 2: Correr el test para verificar que falla**

Run: `flutter test test/core/utils/validators_tarjeta_test.dart`
Expected: FAIL — `The method 'numeroTarjeta' isn't defined for the class 'Validators'`.

- [ ] **Step 3: Implementar los validadores**

En `lib/core/utils/validators.dart`, dentro de la clase `Validators` (antes del `}` de cierre), agregar:

```dart
  static String? numeroTarjeta(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de tarjeta es requerido.';
    }
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[0-9]{16}$').hasMatch(digits)) {
      return 'La tarjeta debe tener 16 dígitos.';
    }
    return null;
  }

  static String? expiracionTarjeta(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La expiración es requerida.';
    }
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value.trim());
    if (match == null) return 'Usa el formato MM/YY.';
    final mes = int.parse(match.group(1)!);
    final anio = 2000 + int.parse(match.group(2)!);
    if (mes < 1 || mes > 12) return 'Mes inválido.';
    final ahora = DateTime.now();
    final ultimoDiaMes = DateTime(anio, mes + 1, 0);
    if (ultimoDiaMes.isBefore(DateTime(ahora.year, ahora.month, 1))) {
      return 'La tarjeta está vencida.';
    }
    return null;
  }

  static String? cvc(String? value) {
    if (value == null || value.trim().isEmpty) return 'El CVC es requerido.';
    if (!RegExp(r'^[0-9]{3}$').hasMatch(value.trim())) {
      return 'El CVC debe tener 3 dígitos.';
    }
    return null;
  }
```

- [ ] **Step 4: Correr el test para verificar que pasa**

Run: `flutter test test/core/utils/validators_tarjeta_test.dart`
Expected: PASS (todos los grupos en verde).

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/validators.dart test/core/utils/validators_tarjeta_test.dart
git commit -m "feat: Modulo 5 - validadores de tarjeta (numero, expiracion, cvc)"
```

---

### Task 2: Dominio del pago + caso de uso `ProcesarPagoUseCase`

**Files:**
- Create: `lib/domain/entities/pago_entity.dart`
- Create: `lib/domain/repositories/pago_repository.dart`
- Create: `lib/domain/usecases/pagos/procesar_pago_usecase.dart`
- Test: `test/domain/usecases/pagos/procesar_pago_usecase_test.dart`

**Interfaces:**
- Consumes: `Validators.numeroTarjeta/expiracionTarjeta/cvc` (Task 1), `ReservaEntity` (existente).
- Produces:
  - `enum EstadoPago { exitoso, fallido }`
  - `PagoEntity` (campos: `id`, `reservaId`, `usuarioId`, `monto` double, `moneda` string default `'usd'`, `metodo` string default `'tarjeta'`, `ultimos4` string, `estado` EstadoPago, `transactionId` String?, `fecha` DateTime).
  - `abstract class PagoRepository { Future<Either<Failure, PagoEntity>> registrarPago(PagoEntity pago); }`
  - `class ProcesarPagoUseCase { ProcesarPagoUseCase(PagoRepository); static const tarjetaExito = '4242424242424242'; Future<Either<Failure, PagoEntity>> call({required ReservaEntity reserva, required String numeroTarjeta, required String expiracion, required String cvc}); }`

- [ ] **Step 1: Crear entidad y repositorio (scaffolding sin test propio)**

Crear `lib/domain/entities/pago_entity.dart`:

```dart
enum EstadoPago { exitoso, fallido }

class PagoEntity {
  final String id;
  final String reservaId;
  final String usuarioId;
  final double monto;
  final String moneda;
  final String metodo;
  final String ultimos4;
  final EstadoPago estado;
  final String? transactionId;
  final DateTime fecha;

  const PagoEntity({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.monto,
    this.moneda = 'usd',
    this.metodo = 'tarjeta',
    required this.ultimos4,
    required this.estado,
    this.transactionId,
    required this.fecha,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PagoEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

Crear `lib/domain/repositories/pago_repository.dart`:

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/pago_entity.dart';

abstract class PagoRepository {
  /// Persiste el pago en `pagos/`. Si el pago es exitoso, además pasa la
  /// reserva asociada a `activa` en la misma transacción. Devuelve el pago
  /// persistido (con id) o un [Failure] ante error de infraestructura.
  Future<Either<Failure, PagoEntity>> registrarPago(PagoEntity pago);
}
```

- [ ] **Step 2: Escribir el test que falla**

Crear `test/domain/usecases/pagos/procesar_pago_usecase_test.dart`:

```dart
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
    result.fold((f) => expect(f, isA<ValidationFailure>()), (_) => fail('esperaba Failure'));
    expect(capturado!.estado, EstadoPago.fallido);
    verify(() => mockRepo.registrarPago(any())).called(1);
  });

  test('tarjeta con formato inválido → ValidationFailure sin tocar el repo', () async {
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
```

- [ ] **Step 3: Correr el test para verificar que falla**

Run: `flutter test test/domain/usecases/pagos/procesar_pago_usecase_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../procesar_pago_usecase.dart'`.

- [ ] **Step 4: Implementar el caso de uso**

Crear `lib/domain/usecases/pagos/procesar_pago_usecase.dart`:

```dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../entities/pago_entity.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/pago_repository.dart';

class ProcesarPagoUseCase {
  final PagoRepository _repo;
  const ProcesarPagoUseCase(this._repo);

  /// Tarjeta de prueba que simula un pago aprobado (estilo Stripe test mode).
  static const tarjetaExito = '4242424242424242';

  Future<Either<Failure, PagoEntity>> call({
    required ReservaEntity reserva,
    required String numeroTarjeta,
    required String expiracion,
    required String cvc,
  }) async {
    final numeroError = Validators.numeroTarjeta(numeroTarjeta);
    if (numeroError != null) return Left(ValidationFailure(numeroError));
    final expError = Validators.expiracionTarjeta(expiracion);
    if (expError != null) return Left(ValidationFailure(expError));
    final cvcError = Validators.cvc(cvc);
    if (cvcError != null) return Left(ValidationFailure(cvcError));

    final numero = numeroTarjeta.replaceAll(RegExp(r'\s'), '');
    final aprobado = numero == tarjetaExito;
    final ahora = DateTime.now();

    final pago = PagoEntity(
      id: '',
      reservaId: reserva.id,
      usuarioId: reserva.usuarioId,
      monto: reserva.montoTotal,
      ultimos4: numero.substring(numero.length - 4),
      estado: aprobado ? EstadoPago.exitoso : EstadoPago.fallido,
      transactionId: aprobado ? 'sim_${ahora.millisecondsSinceEpoch}' : null,
      fecha: ahora,
    );

    final result = await _repo.registrarPago(pago);
    return result.fold(
      (failure) => Left(failure),
      (saved) => saved.estado == EstadoPago.exitoso
          ? Right(saved)
          : const Left(ValidationFailure(
              'Tarjeta declinada. Verifica los datos o usa otra tarjeta.')),
    );
  }
}
```

- [ ] **Step 5: Correr el test para verificar que pasa**

Run: `flutter test test/domain/usecases/pagos/procesar_pago_usecase_test.dart`
Expected: PASS (4 tests en verde).

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/pago_entity.dart lib/domain/repositories/pago_repository.dart lib/domain/usecases/pagos/procesar_pago_usecase.dart test/domain/usecases/pagos/procesar_pago_usecase_test.dart
git commit -m "feat: Modulo 5 - dominio de pago y ProcesarPagoUseCase"
```

---

### Task 3: Ajuste del Módulo 4 — reserva `pendiente` + cancelar/liberar

**Files:**
- Modify: `lib/domain/usecases/reservas/crear_reserva_usecase.dart` (estado inicial)
- Modify: `lib/domain/repositories/reserva_repository.dart` (nuevo método)
- Modify: `lib/data/repositories/reserva_repository_impl.dart` (impl)
- Modify: `lib/data/datasources/remote/reserva_remote_datasource.dart` (transacción cancelar)
- Create: `lib/domain/usecases/reservas/cancelar_reserva_usecase.dart`
- Modify: `test/domain/usecases/reservas/crear_reserva_usecase_test.dart` (esperar `pendiente`)

**Interfaces:**
- Produces:
  - `ReservaRepository.cancelarReserva(ReservaEntity) → Future<Either<Failure, void>>`
  - `ReservaRemoteDatasource.cancelarReserva(ReservaModel) → Future<void>`
  - `CancelarReservaUseCase(ReservaRepository).call(ReservaEntity) → Future<Either<Failure, void>>`
- Consumes: `ReservaEntity`, `ReservaModel` (existentes).

- [ ] **Step 1: Actualizar el test del Módulo 4 (falla primero)**

En `test/domain/usecases/reservas/crear_reserva_usecase_test.dart`, reemplazar el test `'construye la reserva con estado activa y checkInRealizado en false'` (líneas ~105-121) por:

```dart
  test('construye la reserva con estado pendiente y checkInRealizado en false',
      () async {
    ReservaEntity? capturada;
    when(() => mockRepo.crearReserva(any())).thenAnswer((invocation) async {
      capturada = invocation.positionalArguments.first as ReservaEntity;
      return Right(capturada!);
    });

    await callSut();

    expect(capturada!.estado, EstadoReserva.pendiente);
    expect(capturada!.checkInRealizado, isFalse);
    expect(
      capturada!.limiteCheckIn.difference(capturada!.fechaInicio),
      const Duration(minutes: 10),
    );
  });
```

- [ ] **Step 2: Correr el test para verificar que falla**

Run: `flutter test test/domain/usecases/reservas/crear_reserva_usecase_test.dart`
Expected: FAIL — espera `EstadoReserva.pendiente` pero obtiene `activa`.

- [ ] **Step 3: Cambiar el estado inicial de la reserva**

En `lib/domain/usecases/reservas/crear_reserva_usecase.dart`, cambiar:

```dart
      estado: EstadoReserva.activa,
```

por:

```dart
      estado: EstadoReserva.pendiente,
```

- [ ] **Step 4: Correr el test para verificar que pasa**

Run: `flutter test test/domain/usecases/reservas/crear_reserva_usecase_test.dart`
Expected: PASS (5 tests en verde).

- [ ] **Step 5: Agregar `cancelarReserva` al repositorio y datasource**

En `lib/domain/repositories/reserva_repository.dart`, agregar dentro de la clase abstracta:

```dart
  /// Cancela la reserva y libera su espacio (`ocupado → libre`) atómicamente.
  Future<Either<Failure, void>> cancelarReserva(ReservaEntity reserva);
```

En `lib/data/datasources/remote/reserva_remote_datasource.dart`, agregar a la clase abstracta `ReservaRemoteDatasource`:

```dart
  Future<void> cancelarReserva(ReservaModel reserva);
```

y a `ReservaRemoteDatasourceImpl`:

```dart
  @override
  Future<void> cancelarReserva(ReservaModel reserva) async {
    final espacioRef = _db.collection('espacios').doc(reserva.espacioId);
    final reservaRef = _db.collection('reservas').doc(reserva.id);

    await _db.runTransaction((txn) async {
      txn.update(reservaRef, {'estado': 'cancelada'});
      txn.update(espacioRef, {'estado': 'libre'});
    });
  }
```

En `lib/data/repositories/reserva_repository_impl.dart`, agregar el método (e importar `ReservaModel` ya está importado):

```dart
  @override
  Future<Either<Failure, void>> cancelarReserva(ReservaEntity reserva) async {
    try {
      await _datasource.cancelarReserva(ReservaModel.fromEntity(reserva));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al cancelar la reserva: $e'));
    }
  }
```

Crear `lib/domain/usecases/reservas/cancelar_reserva_usecase.dart`:

```dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/reserva_entity.dart';
import '../../repositories/reserva_repository.dart';

class CancelarReservaUseCase {
  final ReservaRepository _repo;
  const CancelarReservaUseCase(this._repo);

  Future<Either<Failure, void>> call(ReservaEntity reserva) =>
      _repo.cancelarReserva(reserva);
}
```

- [ ] **Step 6: Verificar análisis y toda la suite**

Run: `flutter analyze lib/ test/`
Expected: sin errores (solo posibles `info`/`warning` preexistentes).
Run: `flutter test`
Expected: PASS — toda la suite en verde.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/usecases/reservas/crear_reserva_usecase.dart lib/domain/repositories/reserva_repository.dart lib/data/repositories/reserva_repository_impl.dart lib/data/datasources/remote/reserva_remote_datasource.dart lib/domain/usecases/reservas/cancelar_reserva_usecase.dart test/domain/usecases/reservas/crear_reserva_usecase_test.dart
git commit -m "feat: Modulo 5 - reserva inicia pendiente + cancelar/liberar espacio"
```

---

### Task 4: Capa de datos del pago (model + datasource + repo impl)

**Files:**
- Create: `lib/data/models/pago_model.dart`
- Create: `lib/data/datasources/remote/pago_remote_datasource.dart`
- Create: `lib/data/repositories/pago_repository_impl.dart`

**Interfaces:**
- Consumes: `PagoEntity`, `EstadoPago`, `PagoRepository` (Task 2).
- Produces:
  - `PagoModel extends PagoEntity` con `fromEntity`, `fromFirestore`, `toFirestore`.
  - `abstract class PagoRemoteDatasource { Future<PagoModel> registrarPago(PagoModel pago); }` + impl `PagoRemoteDatasourceImpl(FirebaseFirestore)`.
  - `class PagoRepositoryImpl implements PagoRepository` con constructor `PagoRepositoryImpl(PagoRemoteDatasource)`.

> Sin tests unitarios: como en los datasources/models existentes (reserva), la lógica Firestore se verifica con `flutter analyze` y la prueba manual de la Task 6. La lógica de negocio ya está cubierta en la Task 2.

- [ ] **Step 1: Crear `PagoModel`**

Crear `lib/data/models/pago_model.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pago_entity.dart';

class PagoModel extends PagoEntity {
  const PagoModel({
    required super.id,
    required super.reservaId,
    required super.usuarioId,
    required super.monto,
    super.moneda,
    super.metodo,
    required super.ultimos4,
    required super.estado,
    super.transactionId,
    required super.fecha,
  });

  factory PagoModel.fromEntity(PagoEntity e) => PagoModel(
        id: e.id,
        reservaId: e.reservaId,
        usuarioId: e.usuarioId,
        monto: e.monto,
        moneda: e.moneda,
        metodo: e.metodo,
        ultimos4: e.ultimos4,
        estado: e.estado,
        transactionId: e.transactionId,
        fecha: e.fecha,
      );

  factory PagoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PagoModel(
      id: doc.id,
      reservaId: data['reservaId'] as String? ?? '',
      usuarioId: data['usuarioId'] as String? ?? '',
      monto: (data['monto'] as num?)?.toDouble() ?? 0,
      moneda: data['moneda'] as String? ?? 'usd',
      metodo: data['metodo'] as String? ?? 'tarjeta',
      ultimos4: data['ultimos4'] as String? ?? '',
      estado: data['estado'] == 'exitoso'
          ? EstadoPago.exitoso
          : EstadoPago.fallido,
      transactionId: data['transactionId'] as String?,
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reservaId': reservaId,
        'usuarioId': usuarioId,
        'monto': monto,
        'moneda': moneda,
        'metodo': metodo,
        'ultimos4': ultimos4,
        'estado': estado.name,
        'transactionId': transactionId,
        'fecha': Timestamp.fromDate(fecha),
      };
}
```

- [ ] **Step 2: Crear el datasource con transacción**

Crear `lib/data/datasources/remote/pago_remote_datasource.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/pago_entity.dart';
import '../../models/pago_model.dart';

abstract class PagoRemoteDatasource {
  Future<PagoModel> registrarPago(PagoModel pago);
}

class PagoRemoteDatasourceImpl implements PagoRemoteDatasource {
  final FirebaseFirestore _db;
  PagoRemoteDatasourceImpl(this._db);

  @override
  Future<PagoModel> registrarPago(PagoModel pago) async {
    final pagoRef = _db.collection('pagos').doc();

    if (pago.estado == EstadoPago.exitoso) {
      final reservaRef = _db.collection('reservas').doc(pago.reservaId);
      await _db.runTransaction((txn) async {
        txn.set(pagoRef, pago.toFirestore());
        txn.update(reservaRef, {'estado': 'activa'});
      });
    } else {
      await pagoRef.set(pago.toFirestore());
    }

    return PagoModel(
      id: pagoRef.id,
      reservaId: pago.reservaId,
      usuarioId: pago.usuarioId,
      monto: pago.monto,
      moneda: pago.moneda,
      metodo: pago.metodo,
      ultimos4: pago.ultimos4,
      estado: pago.estado,
      transactionId: pago.transactionId,
      fecha: pago.fecha,
    );
  }
}
```

- [ ] **Step 3: Crear el repositorio impl**

Crear `lib/data/repositories/pago_repository_impl.dart`:

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/pago_entity.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/remote/pago_remote_datasource.dart';
import '../models/pago_model.dart';

class PagoRepositoryImpl implements PagoRepository {
  final PagoRemoteDatasource _datasource;
  PagoRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PagoEntity>> registrarPago(PagoEntity pago) async {
    try {
      final saved = await _datasource.registrarPago(PagoModel.fromEntity(pago));
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure('Error al procesar el pago: $e'));
    }
  }
}
```

- [ ] **Step 4: Verificar análisis**

Run: `flutter analyze lib/`
Expected: sin errores.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/pago_model.dart lib/data/datasources/remote/pago_remote_datasource.dart lib/data/repositories/pago_repository_impl.dart
git commit -m "feat: Modulo 5 - capa de datos de pago (model, datasource, repo)"
```

---

### Task 5: Presentación — `PagoViewModel` + `PagoView`

**Files:**
- Create: `lib/presentation/viewmodels/pago_viewmodel.dart`
- Create: `lib/presentation/views/pago/pago_view.dart`

**Interfaces:**
- Consumes: `ProcesarPagoUseCase` (Task 2), `CancelarReservaUseCase` (Task 3), `ReservaEntity`, `PagoEntity`.
- Produces:
  - `enum PagoStatus { idle, procesando, exito, error }`
  - `PagoViewModel({required ProcesarPagoUseCase procesarPagoUseCase, required CancelarReservaUseCase cancelarReservaUseCase})` con `pagar({required ReservaEntity reserva, required String numeroTarjeta, required String expiracion, required String cvc}) → Future<bool>` y `cancelar(ReservaEntity) → Future<void>`; getters `status`, `errorMessage`, `isProcesando`.
  - `PagoView({required ReservaEntity reserva})` (StatefulWidget).

- [ ] **Step 1: Crear el ViewModel**

Crear `lib/presentation/viewmodels/pago_viewmodel.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../domain/entities/pago_entity.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/usecases/pagos/procesar_pago_usecase.dart';
import '../../domain/usecases/reservas/cancelar_reserva_usecase.dart';

enum PagoStatus { idle, procesando, exito, error }

class PagoViewModel extends ChangeNotifier {
  final ProcesarPagoUseCase _procesarPago;
  final CancelarReservaUseCase _cancelarReserva;

  PagoViewModel({
    required ProcesarPagoUseCase procesarPagoUseCase,
    required CancelarReservaUseCase cancelarReservaUseCase,
  })  : _procesarPago = procesarPagoUseCase,
        _cancelarReserva = cancelarReservaUseCase;

  PagoStatus _status = PagoStatus.idle;
  String? _errorMessage;
  PagoEntity? _pago;

  PagoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  PagoEntity? get pago => _pago;
  bool get isProcesando => _status == PagoStatus.procesando;

  Future<bool> pagar({
    required ReservaEntity reserva,
    required String numeroTarjeta,
    required String expiracion,
    required String cvc,
  }) async {
    _status = PagoStatus.procesando;
    _errorMessage = null;
    notifyListeners();

    final result = await _procesarPago(
      reserva: reserva,
      numeroTarjeta: numeroTarjeta,
      expiracion: expiracion,
      cvc: cvc,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = PagoStatus.error;
        notifyListeners();
        return false;
      },
      (pago) {
        _pago = pago;
        _status = PagoStatus.exito;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> cancelar(ReservaEntity reserva) => _cancelarReserva(reserva)
      .then((_) {});
}
```

- [ ] **Step 2: Crear la vista de pago**

Crear `lib/presentation/views/pago/pago_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/entities/reserva_entity.dart';
import '../../viewmodels/pago_viewmodel.dart';

const _primary = Color(0xFF0F766E);
const _dark = Color(0xFF134E4A);

class PagoView extends StatefulWidget {
  final ReservaEntity reserva;
  const PagoView({super.key, required this.reserva});

  @override
  State<PagoView> createState() => _PagoViewState();
}

class _PagoViewState extends State<PagoView> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _expCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pagar(PagoViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await vm.pagar(
      reserva: widget.reserva,
      numeroTarjeta: _numeroCtrl.text,
      expiracion: _expCtrl.text,
      cvc: _cvcCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: _primary, size: 48),
          title: const Text('¡Pago exitoso!'),
          content: Text(
            'Tu reserva quedó confirmada.\nTransacción: ${vm.pago?.transactionId ?? ''}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              child: const Text('Listo'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'No se pudo procesar el pago.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _cancelar(PagoViewModel vm) async {
    await vm.cancelar(widget.reserva);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PagoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total a pagar',
                        style: GoogleFonts.workSans(color: _dark)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.reserva.montoTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Datos de la tarjeta',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, color: _dark, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                validator: Validators.numeroTarjeta,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '4242 4242 4242 4242',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expCtrl,
                      keyboardType: TextInputType.datetime,
                      validator: Validators.expiracionTarjeta,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: Validators.cvc,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba: 4242 4242 4242 4242 aprueba; otra tarjeta se declina.',
                style: GoogleFonts.workSans(
                    fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isProcesando ? null : () => _pagar(vm),
                  child: vm.isProcesando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Pagar \$${widget.reserva.montoTotal.toStringAsFixed(2)}'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: vm.isProcesando ? null : () => _cancelar(vm),
                  child: const Text('Cancelar y liberar espacio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verificar análisis**

Run: `flutter analyze lib/`
Expected: sin errores (la vista aún no está referenciada por el router; eso es la Task 6).

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/viewmodels/pago_viewmodel.dart lib/presentation/views/pago/pago_view.dart
git commit -m "feat: Modulo 5 - PagoViewModel y PagoView"
```

---

### Task 6: Integración — DI, ruta y navegación desde la reserva

**Files:**
- Modify: `lib/core/di/injection.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/presentation/widgets/reserva_sheet.dart`
- Modify: `lib/presentation/views/parking/parqueadero_detail_view.dart`

**Interfaces:**
- Consumes: todo lo anterior. `showReservaSheet` pasa a devolver `Future<ReservaEntity?>` (la reserva creada, o `null`).

- [ ] **Step 1: Registrar dependencias en DI**

En `lib/core/di/injection.dart`, agregar imports (junto a los demás):

```dart
import '../../data/datasources/remote/pago_remote_datasource.dart';
import '../../data/repositories/pago_repository_impl.dart';
import '../../domain/repositories/pago_repository.dart';
import '../../domain/usecases/pagos/procesar_pago_usecase.dart';
import '../../domain/usecases/reservas/cancelar_reserva_usecase.dart';
import '../../presentation/viewmodels/pago_viewmodel.dart';
```

Registrar el datasource (junto a `ReservaRemoteDatasource`):

```dart
  sl.registerLazySingleton<PagoRemoteDatasource>(
      () => PagoRemoteDatasourceImpl(sl()));
```

Registrar el repositorio (junto a `ReservaRepository`):

```dart
  sl.registerLazySingleton<PagoRepository>(() => PagoRepositoryImpl(sl()));
```

Registrar los use cases (en la sección `// Use Cases — Reserva`):

```dart
  sl.registerLazySingleton(() => CancelarReservaUseCase(sl()));
  sl.registerLazySingleton(() => ProcesarPagoUseCase(sl()));
```

Registrar el ViewModel (junto a `ReservaViewModel`):

```dart
  sl.registerFactory(() => PagoViewModel(
        procesarPagoUseCase: sl(),
        cancelarReservaUseCase: sl(),
      ));
```

- [ ] **Step 2: Agregar la ruta `/pago/:reservaId`**

En `lib/core/router/app_router.dart`, agregar imports:

```dart
import '../../domain/entities/reserva_entity.dart';
import '../../presentation/viewmodels/pago_viewmodel.dart';
import '../../presentation/views/pago/pago_view.dart';
```

Agregar la ruta dentro de `routes: [ ... ]` (después de `/parking/:id`):

```dart
          GoRoute(
            path: '/pago/:reservaId',
            builder: (context, state) {
              final reserva = state.extra as ReservaEntity;
              return ChangeNotifierProvider<PagoViewModel>(
                create: (_) => sl<PagoViewModel>(),
                child: PagoView(reserva: reserva),
              );
            },
          ),
```

- [ ] **Step 3: `showReservaSheet` devuelve la reserva creada**

En `lib/presentation/widgets/reserva_sheet.dart`:

Agregar el import de la entidad:

```dart
import '../../domain/entities/reserva_entity.dart';
```

Cambiar la firma y el tipo del modal:

```dart
Future<ReservaEntity?> showReservaSheet(
  BuildContext context, {
  required EspacioEntity espacio,
  required ParqueaderoEntity parqueadero,
  required UserEntity usuario,
}) {
  return showModalBottomSheet<ReservaEntity>(
```

En `_confirmar`, cambiar el `pop(true)` por devolver la reserva creada:

```dart
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(vm.reserva);
    } else {
```

- [ ] **Step 4: Navegar al pago desde el detalle**

En `lib/presentation/views/parking/parqueadero_detail_view.dart`:

Agregar imports:

```dart
import 'package:go_router/go_router.dart';
import '../../../domain/entities/reserva_entity.dart';
```

Reemplazar el bloque final de `_onReservar` (desde `final creada = await showReservaSheet(` hasta el cierre del método) por:

```dart
    final creada = await showReservaSheet(
      context,
      espacio: espacio,
      parqueadero: parqueadero,
      usuario: usuario,
    );

    if (creada is ReservaEntity && context.mounted) {
      context.push('/pago/${creada.id}', extra: creada);
    }
  }
```

- [ ] **Step 5: Verificar análisis y toda la suite**

Run: `flutter analyze lib/ test/`
Expected: sin errores (pueden persistir los `info`/`warning` preexistentes ajenos al módulo).
Run: `flutter test`
Expected: PASS — toda la suite en verde.

- [ ] **Step 6: Prueba manual (en emulador/dispositivo)**

Run: `flutter run`
Verificar el flujo end-to-end:
1. Login como cliente → Home → abrir un parqueadero → tocar un espacio libre → "Reservar" → confirmar reserva.
2. Debe navegar a la pantalla de **Pago** mostrando el monto.
3. Pagar con `4242 4242 4242 4242`, `12/30`, `123` → diálogo "¡Pago exitoso!" → "Listo" vuelve a Home. En Firestore: `pagos/` tiene un doc `exitoso` y la reserva quedó `activa`.
4. Repetir con otra reserva y tarjeta `4000 0000 0000 0002` → SnackBar de tarjeta declinada; la reserva sigue `pendiente` (se puede reintentar); en `pagos/` hay un doc `fallido`.
5. En la pantalla de pago, "Cancelar y liberar espacio" → la reserva pasa a `cancelada` y el espacio vuelve a `libre` (verificar en el grid del detalle en tiempo real).

- [ ] **Step 7: Commit**

```bash
git add lib/core/di/injection.dart lib/core/router/app_router.dart lib/presentation/widgets/reserva_sheet.dart lib/presentation/views/parking/parqueadero_detail_view.dart
git commit -m "feat: Modulo 5 - integra pago (DI, ruta /pago y navegacion desde reserva)"
```

---

### Task 7: Documentación de ejecución

**Files:**
- Create: `docs/execution/modulo5-pago.md`
- Modify: `docs/ESTADO_ACTUAL.md`

- [ ] **Step 1: Escribir `docs/execution/modulo5-pago.md`**

Documentar (siguiendo el formato de `docs/execution/modulo4-reserva.md`): flujo implementado, archivos creados/actualizados, decisiones (pago simulado por tarjeta de prueba, reserva pendiente→activa, colección `pagos/`), tests agregados y total acumulado, y la nueva colección Firestore `pagos/`.

- [ ] **Step 2: Actualizar `docs/ESTADO_ACTUAL.md`**

- Añadir fila del Módulo 5 a "Módulos completados" (plan: `docs/plans/modulo5-pago.md`, ejecución: `docs/execution/modulo5-pago.md`).
- Mover Módulo 5 de "Pendiente" (dejar Módulo 6 y 8).
- Actualizar "Estado técnico verificado" con la fecha y el nuevo total de tests.
- Añadir `pagos` a las colecciones esperadas de Firestore.
- Actualizar la lista de rutas de `go_router` con `/pago/:reservaId`.

- [ ] **Step 3: Commit**

```bash
git add docs/execution/modulo5-pago.md docs/ESTADO_ACTUAL.md
git commit -m "docs: ejecucion Modulo 5 - Pago y actualiza estado actual"
```

---

## Notas de verificación del plan (self-review)

- **Cobertura del spec:** simulación por tarjeta (Task 2) ✓; colección `pagos/` (Task 4) ✓; flujo pendiente→activa (Tasks 3, 4) ✓; cancelar/liberar (Tasks 3, 5, 6) ✓; validadores (Task 1) ✓; ruta dedicada + navegación (Task 6) ✓; distinción formato-inválido (sin escribir) vs declinada (escribe fallido) (Task 2, tests) ✓; actualización del test del Módulo 4 (Task 3) ✓.
- **Fuera de alcance respetado:** sin timeout automático de reservas no pagadas; sin vista de historial de pagos para admin.
- **Consistencia de tipos:** `registrarPago` (repo/datasource/usecase) coincide; `PagoStatus`/`PagoViewModel.pagar` coinciden entre ViewModel (Task 5) y su uso en `PagoView`; `showReservaSheet → Future<ReservaEntity?>` coincide con el consumo en `parqueadero_detail_view` (Task 6).
