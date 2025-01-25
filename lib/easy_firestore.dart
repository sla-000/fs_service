import 'package:fs_service/data/mappers/document_mapper.dart';
import 'package:fs_service/data/repo/easy_firestore_impl.dart';
import 'package:fs_service/data/utils/firestore_path_utils.dart';
import 'package:fs_service/domain/mappers/value_mapper.dart';
import 'package:fs_service/utils/firestore_api_provider.dart';
import 'package:fs_service/utils/path_utils.dart';

export 'package:fs_service/data/mappers/document_mapper.dart';
export 'package:fs_service/data/repo/easy_firestore_impl.dart';
export 'package:fs_service/data/utils/firestore_path_utils.dart';
export 'package:fs_service/domain/mappers/value_mapper.dart';
export 'package:fs_service/utils/path_utils.dart';

/// Example of initialization for your project:
/// ```dart
/// late EasyFirestore firestore;
/// Future<void> initMyFirestore() async {
///   firestore.db.init(
///     /// required
///     projectId: 'projectId',
///     /// optional
///     databaseId: 'databaseId',
///   );
///
///   /// optional, prefix of special fields, by default `$`
///   firestore.db.documentMapper.init(metaPrefix: '_myPrefix');
///
///   /// optional, prefix of special data types,
///   /// see [ValueMapper] for default values
///   firestore.db.documentMapper.valueUtils.init(
///     locationPrefix: '_myLocationPrefix',
///     bytesPrefix: '_myBytesPrefix',
///     datetimePrefix: '_myDatetimePrefix',
///     referencePrefix: '_myReferencePrefix',
///   );
/// }
/// ```
///
/// Add document example:
/// ```dart
/// Future<void> addDocumentExample() async {
//   /// see [test/jsons] directory of the package
//   await firestore.db.addDocument(
//     collectionPath: '/temp',
//     json: {
//       'textField': 'value',
//       'doubleField': 1234.5432,
//       'integerField': 8765,
//       'geopoint': 'location://34.3456/-23.432',
//       'timestamp': 'datetime://2023-10-21T11:26:40.152Z',
//       r'$name': 'document_id',
//     },
//   );
// }
/// ```
class EasyFirestore {
  late FirestoreRepoImpl db;

  Future<void> init({
    required String projectId,
    String databaseId = '(default)',
  }) async {
    const pathUtils = PathUtils();

    db = FirestoreRepoImpl(
      documentMapper: DocumentMapper(
        valueUtils: ValueMapper(),
        pathUtils: pathUtils,
      ),
      firestoreApiProvider: FirestoreApiProviderImpl(),
      firestorePathUtils: FirestorePathUtils(),
      pathUtils: pathUtils,
    );

    await db.init(
      projectId: projectId,
      databaseId: databaseId,
    );
  }

  Future<void> dispose() async => db.dispose();
}
