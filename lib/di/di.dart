import 'package:fs_service/data/mappers/document_mapper.dart';
import 'package:fs_service/data/repo/easy_firestore_impl.dart';
import 'package:fs_service/data/utils/firestore_path_utils.dart';
import 'package:fs_service/domain/mappers/value_mapper.dart';
import 'package:fs_service/domain/repo/easy_firestore.dart';
import 'package:fs_service/utils/firestore_api_provider.dart';
import 'package:fs_service/utils/path_utils.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

extension GetItExt on GetIt {
  void init() {
    di.registerLazySingleton<DocumentMapper>(
      () => DocumentMapper(
        valueUtils: di<ValueMapper>(),
        pathUtils: di<PathUtils>(),
      ),
    );

    di.registerLazySingleton<FirestoreRepo>(
      () => FirestoreRepoImpl(
        documentMapper: di<DocumentMapper>(),
        firestoreApiProvider: di<FirestoreApiProvider>(),
        firestorePathUtils: di<FirestorePathUtils>(),
        pathUtils: di<PathUtils>(),
      ),
      dispose: (e) async => e.dispose(),
    );

    di.registerLazySingleton<FirestoreApiProvider>(
      FirestoreApiProviderImpl.new,
    );

    di.registerLazySingleton<FirestorePathUtils>(FirestorePathUtils.new);

    di.registerLazySingleton<PathUtils>(PathUtils.new);

    di.registerLazySingleton<ValueMapper>(ValueMapper.new);
  }

  Future<void> dispose() async => reset();
}
