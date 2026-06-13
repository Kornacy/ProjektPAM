import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._({FirebaseAuth? firebaseAuth, FirebaseStorage? storage})
      : _firebaseAuthOverride = firebaseAuth,
        _storageOverride = storage;

  static final StorageService instance = StorageService._();

  @visibleForTesting
  factory StorageService.forTesting({
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? storage,
  }) =>
      StorageService._(firebaseAuth: firebaseAuth, storage: storage);

  final FirebaseAuth? _firebaseAuthOverride;
  final FirebaseStorage? _storageOverride;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;

  FirebaseStorage get _storage =>
      _storageOverride ?? FirebaseStorage.instance;

  Future<String> uploadReportPhoto(File photo) async {
    final uid = _firebaseAuth.currentUser?.uid;
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

  Future<void> deleteReportPhoto(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {
      // Plik mógł już nie istnieć w Storage.
    }
  }
}