import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/parqueadero_model.dart';

abstract class ParqueaderoRemoteDatasource {
  Future<List<ParqueaderoModel>> getAll();
}

class ParqueaderoRemoteDatasourceImpl implements ParqueaderoRemoteDatasource {
  final FirebaseFirestore _db;
  ParqueaderoRemoteDatasourceImpl(this._db);

  @override
  Future<List<ParqueaderoModel>> getAll() async {
    final snap = await _db.collection('parqueaderos').get();
    return snap.docs.map(ParqueaderoModel.fromFirestore).toList();
  }
}
