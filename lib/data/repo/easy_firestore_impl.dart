import 'dart:async';

import 'package:fs_service/data/mappers/document_mapper.dart';
import 'package:fs_service/data/utils/firestore_path_utils.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service/domain/repo/easy_firestore.dart';
import 'package:fs_service/utils/firestore_api_provider.dart';
import 'package:fs_service/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';

class FirestoreRepoImpl implements FirestoreRepo {
  FirestoreRepoImpl({
    required this.documentMapper,
    required this.firestoreApiProvider,
    required this.firestorePathUtils,
  });

  final DocumentMapper documentMapper;
  final FirestoreApiProvider firestoreApiProvider;
  final FirestorePathUtils firestorePathUtils;

  ProjectsDatabasesDocumentsResource get firestore =>
      firestoreApiProvider.api.projects.databases.documents;

  @override
  FutureOr<void> init({
    required String projectId,
    String databaseId = '(default)',
  }) async {
    await firestoreApiProvider.init();

    firestorePathUtils.init(
      projectId: projectId,
      databaseId: databaseId,
    );
  }

  @override
  FutureOr<void> dispose() async => firestoreApiProvider.dispose();

  @override
  FutureOr<JsonObject> getCollection({
    required String collectionPath,
    String? changeRootName,
  }) async {
    final collectionParent = di<PathUtils>().parent(collectionPath);
    final collectionName = di<PathUtils>().name(collectionPath);

    final collectionDocuments = await _getCollectionDocuments(
      documentPath:
          firestorePathUtils.absolutePathFromRelative(collectionParent),
      collectionName: collectionName,
    );

    final colJson = JsonObject();
    final docsArrayJson = <JsonObject>[];

    // 1 go through all the documents in the initial collection
    for (final collectionDocument in collectionDocuments) {
      // 2 parse the document
      final docJson = await _getDocumentJson(
        document: collectionDocument,
        json: JsonObject(),
      );

      docsArrayJson.add(docJson);
    }

    colJson[documentMapper.metaName] = collectionName;
    colJson[documentMapper.metaDocuments] = docsArrayJson;

    return colJson;
  }

  Future<List<Document>> _getCollectionDocuments({
    required String documentPath,
    required String collectionName,
  }) async {
    final documents = <Document>[];
    String? pageToken;

    while (true) {
      final listDocumentsResponse = await firestore.listDocuments(
        documentPath,
        collectionName,
        pageToken: pageToken,
        showMissing: true,
      );

      final listDocuments = listDocumentsResponse.documents;
      final nextPageToken = listDocumentsResponse.nextPageToken;

      if (listDocuments != null) {
        documents.addAll(listDocuments);
      }

      if (listDocuments == null || nextPageToken == null) {
        break;
      }

      pageToken = listDocumentsResponse.nextPageToken;
    }

    return documents;
  }

  @override
  FutureOr<JsonObject> getDocument({
    required String documentPath,
    String? changeRootName,
  }) async {
    final docPath = firestorePathUtils.absolutePathFromRelative(documentPath);

    var document = Document(name: docPath);
    try {
      document = await firestore.get(docPath);
    } on DetailedApiRequestError catch (error, _) {
      // Even if document is empty (returns 404) it still can have collections!
      if (error.status != 404) {
        rethrow;
      }
    }

    return _getDocumentJson(document: document, json: JsonObject());
  }

  Future<JsonObject> _getDocumentJson({
    required Document document,
    required JsonObject json,
  }) async {
    final documentJson = documentMapper.documentToJson(document);
    json.addAll(documentJson);

    final documentName = document.name!;
    final collectionNames =
        await _getDocumentCollectionNames(absolutePath: documentName);

    if (collectionNames.isEmpty) {
      return json;
    }

    final allCollectionsArray = await _iterateAllCollectionsOfDocument(
      collectionNames,
      documentName,
    );

    if (allCollectionsArray.isEmpty) {
      return json;
    }

    json[documentMapper.metaCollections] = allCollectionsArray;

    return json;
  }

  Future<List<JsonObject>> _iterateAllCollectionsOfDocument(
    List<String> collectionNames,
    String documentName,
  ) async {
    final allCollectionsArray = <JsonObject>[];

    for (final collectionName in collectionNames) {
      final collectionDocuments = await _getCollectionDocuments(
        documentPath: documentName,
        collectionName: collectionName,
      );

      if (collectionDocuments.isEmpty) {
        continue;
      }

      final allDocumentsInCollection =
          await _iterateAllDocumentsOfCollection(collectionDocuments);

      if (allDocumentsInCollection.isEmpty) {
        continue;
      }

      final oneCollectionJson = JsonObject();
      oneCollectionJson[documentMapper.metaName] = collectionName;
      oneCollectionJson[documentMapper.metaDocuments] =
          allDocumentsInCollection;

      allCollectionsArray.add(oneCollectionJson);
    }

    return allCollectionsArray;
  }

  Future<List<JsonObject>> _iterateAllDocumentsOfCollection(
    List<Document> collectionDocuments,
  ) async {
    final allDocumentsInCollection = <JsonObject>[];

    for (final collectionDocument in collectionDocuments) {
      final documentJson = await _getDocumentJson(
        document: collectionDocument,
        json: JsonObject(),
      );

      allDocumentsInCollection.add(documentJson);
    }
    return allDocumentsInCollection;
  }

  Future<List<String>> _getDocumentCollectionNames({
    String absolutePath = '',
    String path = '',
  }) async {
    assert(
      absolutePath.isNotEmpty != path.isNotEmpty,
      'Only one parameter of absPath or relPath must be used',
    );

    var docPath = absolutePath;

    if (docPath.isEmpty) {
      docPath = firestorePathUtils.absolutePathFromRelative(path);
    }

    final response =
        await firestore.listCollectionIds(ListCollectionIdsRequest(), docPath);

    return response.collectionIds ?? [];
  }

  @override
  FutureOr<void> addDocument({
    required String collectionPath,
    required JsonObject json,
    String? changeRootName,
  }) async {
    await documentMapper.jsonToDocument(
      path: collectionPath,
      json: json,
      onParsed: _onDocumentParsed,
      changeRootName: changeRootName,
    );
  }

  Future<void> _onDocumentParsed(
    String documentPath,
    String? documentId,
    Document document,
  ) async {
    final documentParent = di<PathUtils>().parent(documentPath);
    final absoluteParent =
        firestorePathUtils.absolutePathFromRelative(documentParent);
    final documentName = di<PathUtils>().name(documentPath);

    await firestore.createDocument(
      document,
      absoluteParent,
      documentName,
      documentId: documentId,
    );
  }

  @override
  FutureOr<void> addCollection({
    required String documentPath,
    required JsonObject json,
    String? changeRootName,
  }) async {
    await documentMapper.jsonToCollection(
      path: documentPath,
      json: json,
      onParsed: _onDocumentParsed,
      changeRootName: changeRootName,
    );
  }

  @override
  FutureOr<void> deleteDocument({
    String absolutePath = '',
    String documentPath = '',
  }) async {
    assert(
      absolutePath.isNotEmpty != documentPath.isNotEmpty,
      'Only one parameter of absolutePath or documentPath must be used',
    );

    var docPath = absolutePath;

    if (docPath.isEmpty) {
      docPath = firestorePathUtils.absolutePathFromRelative(documentPath);
    }

    final collectionNames =
        await _getDocumentCollectionNames(absolutePath: docPath);

    for (final collectionName in collectionNames) {
      final collectionPath = di<PathUtils>().join(docPath, collectionName);

      await deleteCollection(absolutePath: collectionPath);
    }

    await firestore.delete(docPath);
  }

  @override
  FutureOr<void> deleteCollection({
    String absolutePath = '',
    String collectionPath = '',
  }) async {
    assert(
      absolutePath.isNotEmpty != collectionPath.isNotEmpty,
      'Only one parameter of absolutePath or documentPath must be used',
    );

    var colPath = absolutePath;

    if (colPath.isEmpty) {
      colPath = firestorePathUtils.absolutePathFromRelative(collectionPath);
    }

    final collectionParent = di<PathUtils>().parent(colPath);
    final collectionName = di<PathUtils>().name(colPath);

    final documents = await _getCollectionDocuments(
      documentPath: collectionParent,
      collectionName: collectionName,
    );

    for (final document in documents) {
      if (document.name != null) {
        await deleteDocument(absolutePath: document.name!);
      }
    }
  }
}
