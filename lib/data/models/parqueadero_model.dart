import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parqueadero_entity.dart';

class ParqueaderoModel extends ParqueaderoEntity {
  const ParqueaderoModel({
    required super.id,
    required super.nombre,
    required super.direccion,
    required super.lat,
    required super.lng,
    required super.capacidadTotal,
    required super.espaciosDisponibles,
    required super.tarifaPorHora,
    required super.horario,
    required super.adminId,
  });

  factory ParqueaderoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final ubicacion = data['ubicacion'] as GeoPoint;
    return ParqueaderoModel(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      direccion: data['direccion'] as String? ?? '',
      lat: ubicacion.latitude,
      lng: ubicacion.longitude,
      capacidadTotal: (data['capacidadTotal'] as num?)?.toInt() ?? 0,
      espaciosDisponibles: (data['espaciosDisponibles'] as num?)?.toInt() ?? 0,
      tarifaPorHora: (data['tarifaPorHora'] as num?)?.toDouble() ?? 0.0,
      horario: data['horario'] as String? ?? '',
      adminId: data['adminId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'direccion': direccion,
        'ubicacion': GeoPoint(lat, lng),
        'capacidadTotal': capacidadTotal,
        'espaciosDisponibles': espaciosDisponibles,
        'tarifaPorHora': tarifaPorHora,
        'horario': horario,
        'adminId': adminId,
      };
}
