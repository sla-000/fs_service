import 'package:fs_service_lib/data/mappers/document_mapper.dart';
import 'package:fs_service_lib/data/utils/firestore_path_utils.dart';
import 'package:fs_service_lib/utils/firestore_api_provider.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../lib/data/repo/easy_firestore_impl.dart';
import '../../../lib/utils/path_utils.dart';

class _MockDocumentMapper extends Mock implements DocumentMapper {}

class _MockFirestoreApiProvider extends Mock implements FirestoreApiProvider {}

class _MockFirestorePathUtils extends Mock implements FirestorePathUtils {}

class _MockFirestoreApi extends Mock implements FirestoreApi {}

class _MockProjectsResource extends Mock implements ProjectsResource {}

class _MockProjectsDatabasesResource extends Mock
    implements ProjectsDatabasesResource {}

class _MockProjectsDatabasesDocumentsResource extends Mock
    implements ProjectsDatabasesDocumentsResource {}

class _MockPathUtils extends Mock implements PathUtils {}

final _mockDocumentMapper = _MockDocumentMapper();
final _mockFirestoreApiProvider = _MockFirestoreApiProvider();
final _mockFirestorePathUtils = _MockFirestorePathUtils();
final _mockFirestoreApi = _MockFirestoreApi();
final _mockProjectsResource = _MockProjectsResource();
final _mockProjectsDatabasesResource = _MockProjectsDatabasesResource();
final _mockProjectsDatabasesDocumentsResource =
    _MockProjectsDatabasesDocumentsResource();
final _mockPathUtils = _MockPathUtils();

const _projectId = '_projectId';
const _databaseId = '_databaseId';

const _absolutePath = '_absolutePath';
const _relativePath = '_relativePath';

const _joinedPath = '_joinedPath';

const _name = '_name';
const _parent = '_parent';

final _document1 = Document(name: '_document1');
final _document2 = Document(name: '_document2');

void main() {
  final easyFirestore = FirestoreRepoImpl(
    documentMapper: _mockDocumentMapper,
    firestoreApiProvider: _mockFirestoreApiProvider,
    firestorePathUtils: _mockFirestorePathUtils,
    pathUtils: _mockPathUtils,
  );

  setUpAll(() async {
    registerFallbackValue(ListCollectionIdsRequest());

    // di.registerLazySingleton<PathUtils>(() => _mockPathUtils);

    when(_mockFirestoreApiProvider.init).thenAnswer((_) async {});

    when(() => _mockFirestoreApiProvider.api).thenReturn(_mockFirestoreApi);

    when(() => _mockFirestoreApi.projects).thenReturn(_mockProjectsResource);

    when(() => _mockProjectsResource.databases)
        .thenReturn(_mockProjectsDatabasesResource);

    when(() => _mockProjectsDatabasesResource.documents)
        .thenReturn(_mockProjectsDatabasesDocumentsResource);

    when(
      () => _mockProjectsDatabasesDocumentsResource.listCollectionIds(
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async => ListCollectionIdsResponse(collectionIds: ['1', '2']),
    );

    when(() => _mockPathUtils.join(any(), any())).thenReturn(_joinedPath);

    when(() => _mockPathUtils.parent(any())).thenReturn(_parent);
    when(() => _mockPathUtils.name(any())).thenReturn(_name);

    when(
      () => _mockProjectsDatabasesDocumentsResource.listDocuments(
        any(),
        any(),
        pageToken: any(named: 'pageToken'),
        showMissing: true,
      ),
    ).thenAnswer(
      (_) async => ListDocumentsResponse(
        documents: [_document1, _document2],
      ),
    );

    await easyFirestore.init(
      projectId: _projectId,
      databaseId: _databaseId,
    );
  });

  tearDown(() {
    reset(_mockDocumentMapper);
    reset(_mockFirestoreApiProvider);
  });

  group(
    'EasyFirestore tests - ',
    () {
      group(
        'deleteDocument tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo deleteDocument tests
            },
          );
        },
      );

      group(
        'deleteCollection tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo deleteCollection tests
            },
          );
        },
      );

      group(
        'getDocument tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo getDocument tests
            },
          );
        },
      );

      group(
        'getCollection tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo getCollection tests
            },
          );
        },
      );

      group(
        'addDocument tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo addDocument tests
            },
          );
        },
      );

      group(
        'updateDocument tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo addDocument tests
            },
          );
        },
      );

      group(
        'addCollection tests - ',
        () {
          test(
            'smoke test',
            () async {
              // todo addCollection tests
            },
          );
        },
      );
    },
  );
}
