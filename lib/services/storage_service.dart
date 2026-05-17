import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReportPhoto(File photo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Użytkownik nie jest zalogowany.');

    final String path =
        'reports/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final UploadTask task = _storage.ref(path).putFile(
          photo,
          SettableMetadata(contentType: 'image/jpeg'),
        );

    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }
}