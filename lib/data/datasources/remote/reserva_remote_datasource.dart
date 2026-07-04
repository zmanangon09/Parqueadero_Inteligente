import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reserva_model.dart';

/// Se lanza dentro de la transacción cuando el espacio ya no está `libre`.
class EspacioNoDisponibleException implements Exception {}

abstract class ReservaRemoteDatasource {
  Future<ReservaModel> crearReserva(ReservaModel reserva);
  Future<List<ReservaModel>> getAllReservas();
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
      txn.set(reservaRef, reserva.toFirestore());
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
      qrCode: reserva.qrCode,
    );
  }

  @override
  Future<List<ReservaModel>> getAllReservas() async {
    final snap = await _db.collection('reservas').get();
    return snap.docs.map(ReservaModel.fromFirestore).toList();
  }
}
