import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reserva_model.dart';

/// Se lanza dentro de la transacción cuando el espacio ya no está `libre`.
class EspacioNoDisponibleException implements Exception {}

abstract class ReservaRemoteDatasource {
  Future<ReservaModel> crearReserva(ReservaModel reserva);
  Future<List<ReservaModel>> getAllReservas();
  Future<List<ReservaModel>> getReservasByUsuario(String usuarioId);
  Future<void> cancelarReserva(ReservaModel reserva);

  /// El contenido del QR es el id del documento de la reserva.
  Future<ReservaModel?> getReservaByQr(String qr);
  Future<void> checkIn(ReservaModel reserva);
  Future<void> checkOut(ReservaModel reserva);

  /// Cancela reservas cuya ventana de check-in expiró sin check-in y libera
  /// sus espacios. Devuelve cuántas liberó.
  Future<int> liberarReservasExpiradas();
}

class ReservaRemoteDatasourceImpl implements ReservaRemoteDatasource {
  final FirebaseFirestore _db;
  ReservaRemoteDatasourceImpl(this._db);

  @override
  Future<ReservaModel> crearReserva(ReservaModel reserva) async {
    final espacioRef = _db.collection('espacios').doc(reserva.espacioId);
    final reservaRef = _db.collection('reservas').doc();

    await _db.runTransaction((txn) async {
      final espacioSnap = await txn.get(espacioRef);
      final estado = espacioSnap.data()?['estado'] as String?;
      if (!espacioSnap.exists || estado != 'libre') {
        throw EspacioNoDisponibleException();
      }
      txn.update(espacioRef, {'estado': 'ocupado'});
      txn.update(
        _db.collection('parqueaderos').doc(reserva.parqueaderoId),
        {'espaciosDisponibles': FieldValue.increment(-1)},
      );
      // El QR de la reserva es su propio id de documento.
      txn.set(reservaRef,
          reserva.toFirestore()..['qrCode'] = reservaRef.id);
    });

    return ReservaModel(
      id: reservaRef.id,
      usuarioId: reserva.usuarioId,
      espacioId: reserva.espacioId,
      parqueaderoId: reserva.parqueaderoId,
      placa: reserva.placa,
      fechaInicio: reserva.fechaInicio,
      fechaFin: reserva.fechaFin,
      montoTotal: reserva.montoTotal,
      estado: reserva.estado,
      limiteCheckIn: reserva.limiteCheckIn,
      checkInRealizado: reserva.checkInRealizado,
      qrCode: reservaRef.id,
    );
  }

  @override
  Future<List<ReservaModel>> getAllReservas() async {
    final snap = await _db.collection('reservas').get();
    return snap.docs.map(ReservaModel.fromFirestore).toList();
  }

  @override
  Future<List<ReservaModel>> getReservasByUsuario(String usuarioId) async {
    final snap = await _db
        .collection('reservas')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();
    final list = snap.docs.map(ReservaModel.fromFirestore).toList();
    // Orden client-side (más reciente primero) para no requerir índice compuesto.
    list.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
    return list;
  }

  @override
  Future<void> cancelarReserva(ReservaModel reserva) async {
    final espacioRef = _db.collection('espacios').doc(reserva.espacioId);
    final reservaRef = _db.collection('reservas').doc(reserva.id);

    await _db.runTransaction((txn) async {
      txn.update(reservaRef, {'estado': 'cancelada'});
      txn.update(espacioRef, {'estado': 'libre'});
      txn.update(
        _db.collection('parqueaderos').doc(reserva.parqueaderoId),
        {'espaciosDisponibles': FieldValue.increment(1)},
      );
    });
  }

  @override
  Future<ReservaModel?> getReservaByQr(String qr) async {
    final doc = await _db.collection('reservas').doc(qr).get();
    if (!doc.exists) return null;
    return ReservaModel.fromFirestore(doc);
  }

  @override
  Future<void> checkIn(ReservaModel reserva) =>
      _db.collection('reservas').doc(reserva.id).update({
        'checkInRealizado': true,
      });

  @override
  Future<void> checkOut(ReservaModel reserva) async {
    final espacioRef = _db.collection('espacios').doc(reserva.espacioId);
    final reservaRef = _db.collection('reservas').doc(reserva.id);

    await _db.runTransaction((txn) async {
      txn.update(reservaRef, {'estado': 'completada'});
      txn.update(espacioRef, {'estado': 'libre'});
      txn.update(
        _db.collection('parqueaderos').doc(reserva.parqueaderoId),
        {'espaciosDisponibles': FieldValue.increment(1)},
      );
    });
  }

  @override
  Future<int> liberarReservasExpiradas() async {
    // ponytail: barrido lazy al abrir pantallas en lugar de Cloud Functions;
    // suficiente para el alcance académico.
    final snap = await _db
        .collection('reservas')
        .where('estado', whereIn: ['pendiente', 'activa']).get();

    final ahora = DateTime.now();
    final expiradas = snap.docs.where((d) {
      final data = d.data();
      final checkIn = data['checkInRealizado'] as bool? ?? false;
      final limite = (data['limiteCheckIn'] as Timestamp?)?.toDate();
      return !checkIn && limite != null && ahora.isAfter(limite);
    }).toList();

    if (expiradas.isEmpty) return 0;

    final batch = _db.batch();
    final incrementosPorParqueadero = <String, int>{};
    for (final doc in expiradas) {
      final data = doc.data();
      batch.update(doc.reference, {'estado': 'cancelada'});
      batch.update(
        _db.collection('espacios').doc(data['espacioId'] as String),
        {'estado': 'libre'},
      );
      final pid = data['parqueaderoId'] as String;
      incrementosPorParqueadero[pid] =
          (incrementosPorParqueadero[pid] ?? 0) + 1;
    }
    incrementosPorParqueadero.forEach((pid, n) {
      batch.update(_db.collection('parqueaderos').doc(pid),
          {'espaciosDisponibles': FieldValue.increment(n)});
    });
    await batch.commit();
    return expiradas.length;
  }
}
