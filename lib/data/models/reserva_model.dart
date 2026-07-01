import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reserva_entity.dart';

class ReservaModel extends ReservaEntity {
  const ReservaModel({
    required super.id,
    required super.usuarioId,
    required super.espacioId,
    required super.parqueaderoId,
    required super.placa,
    required super.fechaInicio,
    required super.fechaFin,
    required super.montoTotal,
    required super.estado,
    required super.limiteCheckIn,
    super.checkInRealizado,
    super.qrCode,
  });

  factory ReservaModel.fromEntity(ReservaEntity e) => ReservaModel(
        id: e.id,
        usuarioId: e.usuarioId,
        espacioId: e.espacioId,
        parqueaderoId: e.parqueaderoId,
        placa: e.placa,
        fechaInicio: e.fechaInicio,
        fechaFin: e.fechaFin,
        montoTotal: e.montoTotal,
        estado: e.estado,
        limiteCheckIn: e.limiteCheckIn,
        checkInRealizado: e.checkInRealizado,
        qrCode: e.qrCode,
      );

  factory ReservaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ReservaModel(
      id: doc.id,
      usuarioId: data['usuarioId'] as String? ?? '',
      espacioId: data['espacioId'] as String? ?? '',
      parqueaderoId: data['parqueaderoId'] as String? ?? '',
      placa: data['placa'] as String? ?? '',
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      montoTotal: (data['montoTotal'] as num?)?.toDouble() ?? 0,
      estado: _parseEstado(data['estado'] as String?),
      limiteCheckIn: (data['limiteCheckIn'] as Timestamp).toDate(),
      checkInRealizado: data['checkInRealizado'] as bool? ?? false,
      qrCode: data['qrCode'] as String?,
    );
  }

  static EstadoReserva _parseEstado(String? raw) => switch (raw) {
        'pendiente' => EstadoReserva.pendiente,
        'completada' => EstadoReserva.completada,
        'cancelada' => EstadoReserva.cancelada,
        _ => EstadoReserva.activa,
      };

  Map<String, dynamic> toFirestore() => {
        'usuarioId': usuarioId,
        'espacioId': espacioId,
        'parqueaderoId': parqueaderoId,
        'placa': placa,
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': Timestamp.fromDate(fechaFin),
        'montoTotal': montoTotal,
        'estado': estado.name,
        'limiteCheckIn': Timestamp.fromDate(limiteCheckIn),
        'checkInRealizado': checkInRealizado,
        'qrCode': qrCode,
      };
}
