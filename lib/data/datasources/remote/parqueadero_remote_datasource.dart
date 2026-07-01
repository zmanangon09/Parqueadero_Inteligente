import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/parqueadero_model.dart';

abstract class ParqueaderoRemoteDatasource {
  Future<List<ParqueaderoModel>> getAll();
  Future<ParqueaderoModel> getById(String id);
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
}
