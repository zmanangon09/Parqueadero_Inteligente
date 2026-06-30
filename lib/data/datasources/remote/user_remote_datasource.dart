import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> createUserDoc(UserModel user);
  Future<UserModel> getUserDoc(String uid);
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
}
