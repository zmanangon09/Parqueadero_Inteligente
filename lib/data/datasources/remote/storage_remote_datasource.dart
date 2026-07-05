import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageRemoteDatasource {
  /// Sube la foto de perfil y devuelve su URL pública de descarga.
  Future<String> uploadFotoPerfil(String uid, String filePath);
}

class StorageRemoteDatasourceImpl implements StorageRemoteDatasource {
  final FirebaseStorage _storage;
  StorageRemoteDatasourceImpl(this._storage);

  @override
  Future<String> uploadFotoPerfil(String uid, String filePath) async {
    final ref = _storage.ref('perfiles/$uid.jpg');
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }
}
