import 'dart:async';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

abstract class FirestoreApiProvider {
  FirestoreApi get api;

  FutureOr<void> init();

  FutureOr<void> dispose();
}

class FirestoreApiProviderImpl implements FirestoreApiProvider {
  FirestoreApiProviderImpl();

  @override
  late FirestoreApi api;

  late AuthClient _client;

  @override
  Future<void> init() async {
    _client = await clientViaApplicationDefaultCredentials(
      scopes: [
        FirestoreApi.cloudPlatformScope,
        FirestoreApi.datastoreScope,
      ],
    );

    api = FirestoreApi(_client);
  }

  @override
  void dispose() => _client.close();
}
