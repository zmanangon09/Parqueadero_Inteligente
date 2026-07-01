import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/espacio_entity.dart';

class EspacioModel extends EspacioEntity {
  const EspacioModel({
    required super.id,
    required super.parqueaderoId,
    required super.numero,
    required super.estado,
    required super.tipo,
  });

  factory EspacioModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return EspacioModel(
      id: doc.id,
      parqueaderoId: data['parqueaderoId'] as String? ?? '',
      numero: (data['numero'] as num?)?.toInt() ?? 0,
      estado: _parseEstado(data['estado'] as String?),
      tipo: _parseTipo(data['tipo'] as String?),
    );
  }

  static EstadoEspacio _parseEstado(String? raw) => switch (raw) {
        'ocupado' => EstadoEspacio.ocupado,
        'reservado' => EstadoEspacio.reservado,
        _ => EstadoEspacio.libre,
      };

  static TipoEspacio _parseTipo(String? raw) => switch (raw) {
        'discapacitado' => TipoEspacio.discapacitado,
        'electrico' => TipoEspacio.electrico,
        _ => TipoEspacio.normal,
      };

  Map<String, dynamic> toFirestore() => {
        'parqueaderoId': parqueaderoId,
        'numero': numero,
        'estado': estado.name,
        'tipo': tipo.name,
      };
}
