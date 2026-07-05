import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/espacio_model.dart';
import '../../models/parqueadero_model.dart';

abstract class ParqueaderoRemoteDatasource {
  Future<List<ParqueaderoModel>> getAll();
  Future<ParqueaderoModel> getById(String id);
  Future<void> saveParqueadero(ParqueaderoModel parqueadero, List<EspacioModel> espacios);
  Future<int> getParqueaderosCount();
  Future<void> liberarEspacios(String parqueaderoId);
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

  @override
  Future<void> liberarEspacios(String parqueaderoId) async {
    final espaciosSnap = await _db
        .collection('espacios')
        .where('parqueaderoId', isEqualTo: parqueaderoId)
        .get();
    final reservasSnap = await _db
        .collection('reservas')
        .where('parqueaderoId', isEqualTo: parqueaderoId)
        .get();

    final batch = _db.batch();
    for (final doc in espaciosSnap.docs) {
      batch.update(doc.reference, {'estado': 'libre'});
    }
    // Filtro client-side para no requerir índice compuesto (parqueaderoId + estado).
    for (final doc in reservasSnap.docs) {
      final estado = doc.data()['estado'];
      if (estado == 'activa' || estado == 'pendiente') {
        batch.update(doc.reference, {'estado': 'cancelada'});
      }
    }
    batch.update(
      _db.collection('parqueaderos').doc(parqueaderoId),
      {'espaciosDisponibles': espaciosSnap.docs.length},
    );
    await batch.commit();
  }
}
