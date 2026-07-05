import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/espacio_model.dart';

abstract class EspacioRemoteDatasource {
  Stream<List<EspacioModel>> watchEspaciosByParqueadero(String parqueaderoId);
  Future<List<EspacioModel>> getEspaciosByParqueadero(String parqueaderoId);

  /// Actualiza en batch el estado de varios espacios y recalcula
  /// `espaciosDisponibles` del parqueadero.
  Future<void> actualizarEstados(
    String parqueaderoId,
    Map<String, String> estadoPorEspacioId,
    int espaciosDisponibles,
  );
}

class EspacioRemoteDatasourceImpl implements EspacioRemoteDatasource {
  final FirebaseFirestore _db;
  EspacioRemoteDatasourceImpl(this._db);

  @override
  Stream<List<EspacioModel>> watchEspaciosByParqueadero(
    String parqueaderoId,
  ) =>
      _db
          .collection('espacios')
          .where('parqueaderoId', isEqualTo: parqueaderoId)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map(EspacioModel.fromFirestore).toList();
        // Orden client-side por número: evita requerir un índice compuesto
        // (where + orderBy) en Firestore. La lista de espacios es pequeña.
        list.sort((a, b) => a.numero.compareTo(b.numero));
        return list;
      });

  @override
  Future<List<EspacioModel>> getEspaciosByParqueadero(
    String parqueaderoId,
  ) async {
    final snap = await _db
        .collection('espacios')
        .where('parqueaderoId', isEqualTo: parqueaderoId)
        .get();
    final list = snap.docs.map(EspacioModel.fromFirestore).toList();
    list.sort((a, b) => a.numero.compareTo(b.numero));
    return list;
  }

  @override
  Future<void> actualizarEstados(
    String parqueaderoId,
    Map<String, String> estadoPorEspacioId,
    int espaciosDisponibles,
  ) async {
    final batch = _db.batch();
    estadoPorEspacioId.forEach((id, estado) {
      batch.update(_db.collection('espacios').doc(id), {'estado': estado});
    });
    batch.update(
      _db.collection('parqueaderos').doc(parqueaderoId),
      {'espaciosDisponibles': espaciosDisponibles},
    );
    await batch.commit();
  }
}
