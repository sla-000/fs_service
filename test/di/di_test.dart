import 'package:fs_service/data/mappers/document_mapper.dart';
import 'package:fs_service/data/utils/firestore_path_utils.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service/domain/mappers/value_mapper.dart';
import 'package:fs_service/domain/repo/easy_firestore.dart';
import 'package:fs_service/utils/firestore_api_provider.dart';
import 'package:fs_service/utils/path_utils.dart';
import 'package:test/test.dart';

void main() {
  group(
    'DI tests - ',
    () {
      setUpAll(di.init);

      tearDownAll(() async => di.dispose());

      test(
        'isRegistered tests',
        () async {
          expect(di.isRegistered<DocumentMapper>(), isTrue);
          expect(di.isRegistered<FirestoreRepo>(), isTrue);
          expect(di.isRegistered<FirestoreApiProvider>(), isTrue);
          expect(di.isRegistered<FirestorePathUtils>(), isTrue);
          expect(di.isRegistered<PathUtils>(), isTrue);
          expect(di.isRegistered<ValueMapper>(), isTrue);
        },
      );
    },
  );
}
