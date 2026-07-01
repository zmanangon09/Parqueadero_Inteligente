import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/espacio_model.dart';

abstract class EspacioRemoteDatasource {
  Stream<List<EspacioModel>> watchEspaciosByParqueadero(String parqueaderoId);
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
}
