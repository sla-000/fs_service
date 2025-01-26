import 'dart:async';

typedef JsonObject = Map<String, dynamic>;

abstract class FirestoreRepo {
  FutureOr<void> init({
    required String projectId,
    String databaseId = '(default)',
  });

  FutureOr<void> dispose();

  FutureOr<JsonObject> getCollection({
    required String collectionPath,
  });

  FutureOr<JsonObject> getDocument({
    required String documentPath,
  });

  FutureOr<void> addDocument({
    required String collectionPath,
    required JsonObject json,
    String? changeRootName,
  });

  FutureOr<void> updateDocument({
    required String documentPath,
    required JsonObject json,
  });

  FutureOr<void> addCollection({
    required String documentPath,
    required JsonObject json,
    String? changeRootName,
  });

  FutureOr<void> deleteDocument({
    String absolutePath = '',
    String documentPath = '',
  });

  FutureOr<void> deleteCollection({
    required String collectionPath,
  });
}
