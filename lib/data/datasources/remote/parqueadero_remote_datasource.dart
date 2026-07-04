import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/espacio_model.dart';
import '../../models/parqueadero_model.dart';

abstract class ParqueaderoRemoteDatasource {
  Future<List<ParqueaderoModel>> getAll();
  Future<ParqueaderoModel> getById(String id);
  Future<void> saveParqueadero(ParqueaderoModel parqueadero, List<EspacioModel> espacios);
  Future<int> getParqueaderosCount();
}

class ParqueaderoRemoteDatasourceImpl implements ParqueaderoRemoteDatasource {
  final FirebaseFirestore _db;
  ParqueaderoRemoteDatasourceImpl(this._db);

  @override
  Future<List<ParqueaderoModel>> getAll() async {
    final snap = await _db.collection('parqueaderos').get();
    return snap.docs.map(ParqueaderoModel.fromFirestore).toList();
  }

  @override
  Future<ParqueaderoModel> getById(String id) async {
    final doc = await _db.collection('parqueaderos').doc(id).get();
    if (!doc.exists) throw Exception('Parqueadero no encontrado');
    return ParqueaderoModel.fromFirestore(doc);
  }

  @override
  Future<void> saveParqueadero(
    ParqueaderoModel parqueadero,
    List<EspacioModel> espacios,
  ) async {
    final batch = _db.batch();
    
    final docRef = parqueadero.id.isEmpty
        ? _db.collection('parqueaderos').doc()
        : _db.collection('parqueaderos').doc(parqueadero.id);
    
    final id = docRef.id;

    final pqModel = ParqueaderoModel(
      id: id,
      nombre: parqueadero.nombre,
      direccion: parqueadero.direccion,
      lat: parqueadero.lat,
      lng: parqueadero.lng,
      capacidadTotal: parqueadero.capacidadTotal,
      espaciosDisponibles: parqueadero.espaciosDisponibles,
      tarifaPorHora: parqueadero.tarifaPorHora,
      horario: parqueadero.horario,
      adminId: parqueadero.adminId,
    );

    batch.set(docRef, pqModel.toFirestore());

    for (final esp in espacios) {
      final espRef = _db.collection('espacios').doc();
      final espModel = EspacioModel(
        id: espRef.id,
        parqueaderoId: id,
        numero: esp.numero,
        estado: esp.estado,
        tipo: esp.tipo,
      );
      batch.set(espRef, espModel.toFirestore());
    }

    await batch.commit();
  }

  @override
  Future<int> getParqueaderosCount() async {
    final snap = await _db.collection('parqueaderos').count().get();
    return snap.count ?? 0;
  }
}
