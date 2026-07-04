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
