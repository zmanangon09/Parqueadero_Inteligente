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
