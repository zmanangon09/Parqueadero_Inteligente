import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> createUserDoc(UserModel user);
  Future<UserModel> getUserDoc(String uid);
  Future<int> getUsersCount();
  Future<List<UserModel>> getAllUsers();
  Future<void> updateVehiculos(String uid, List<String> vehiculos);
  Future<void> updateFotoUrl(String uid, String fotoUrl);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  const UserRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  @override
  Future<void> createUserDoc(UserModel user) =>
      _usuarios.doc(user.uid).set(user.toFirestore());

  @override
  Future<UserModel> getUserDoc(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) throw Exception('Usuario no encontrado: $uid');
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<int> getUsersCount() async {
    final snap = await _usuarios.count().get();
    return snap.count ?? 0;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snap = await _usuarios.get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  @override
  Future<void> updateVehiculos(String uid, List<String> vehiculos) =>
      _usuarios.doc(uid).update({'vehiculos': vehiculos});

  @override
  Future<void> updateFotoUrl(String uid, String fotoUrl) =>
      _usuarios.doc(uid).update({'fotoUrl': fotoUrl});
}
