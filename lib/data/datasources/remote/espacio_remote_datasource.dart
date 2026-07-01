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
          .orderBy('numero')
          .snapshots()
          .map((snap) => snap.docs.map(EspacioModel.fromFirestore).toList());
}
