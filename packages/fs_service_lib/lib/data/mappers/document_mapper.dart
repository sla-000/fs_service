import 'dart:async';

import 'package:fs_service_lib/data/utils/document_ext.dart';
import 'package:fs_service_lib/domain/mappers/value_mapper.dart';
import 'package:fs_service_lib/domain/repo/easy_firestore.dart';
import 'package:fs_service_lib/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';

typedef OnParsedCallback = Future<void> Function(
  String relativePath,
  String? documentId,
  Document document,
);

class DocumentMapper {
  DocumentMapper({
    required this.valueUtils,
    required this.pathUtils,
  });

  final ValueMapper valueUtils;
  final PathUtils pathUtils;

  static const kDefaultMetaPrefix = r'$';

  late String _metaPrefix;

  void init({
    String? metaPrefix,
  }) {
    _metaPrefix = metaPrefix ?? kDefaultMetaPrefix;
  }

  String get metaName => '${_metaPrefix}name';
  String get metaCollections => '${_metaPrefix}collections';
  String get metaDocuments => '${_metaPrefix}documents';
  String get metaCreateTime => '${_metaPrefix}createTime';
  String get metaUpdateTime => '${_metaPrefix}updateTime';

  JsonObject documentToJson(Document document) {
    final docJson = <String, dynamic>{};

    final entries = document.fields?.entries ?? [];

    for (final entry in entries) {
      docJson[entry.key] = valueUtils.toJsonObject(entry.value);
    }

    docJson[metaName] = document.id(pathUtils);

    if (document.createTime != null) {
      final createTime =
          DateTime.tryParse(document.createTime!)?.toUtc().toIso8601String();
      docJson[metaCreateTime] = createTime;
    }

    if (document.updateTime != null) {
      final updateTime =
          DateTime.tryParse(document.updateTime!)?.toUtc().toIso8601String();
      docJson[metaUpdateTime] = updateTime;
    }

    return docJson;
  }

  JsonObject collectionToJson({
    required String path,
    List<Document> documents = const [],
  }) {
    final docsJson = JsonObject();

    docsJson[metaName] = path;
    docsJson[metaDocuments] =
        documents.map(documentToJson).toList(growable: false);

    return docsJson;
  }

  Future<void> jsonToDocument({
    required String path,
    required JsonObject json,
    required OnParsedCallback onParsed,
    String? changeRootName,
  }) async {
    final (id, document) = _jsonToDocument(json);

    final name = changeRootName ?? id;

    await onParsed(path, name, document);

    final rawDocumentCollections = json[metaCollections] ?? [];
    if (rawDocumentCollections is! List<dynamic>) {
      throw FormatException(
          'Wrong `$metaCollections` value=`$rawDocumentCollections` '
          'in json=`$json`');
    }

    final documentCollections = rawDocumentCollections.cast<JsonObject>();

    final documentPath = pathUtils.join(path, name);

    for (final documentCollection in documentCollections) {
      final documentCollectionName =
          documentCollection[metaName] as String? ?? '';
      if (documentCollectionName.isEmpty) {
        continue;
      }

      await jsonToCollection(
        path: documentPath,
        json: documentCollection,
        onParsed: onParsed,
      );
    }
  }

  (String? id, Document document) _jsonToDocument(JsonObject inJson) {
    final jsonCopy = Map.of(inJson);

    final name = jsonCopy[metaName];
    if (name is! String?) {
      throw FormatException('Wrong `$metaName` value=`$name` '
          'in json=`$inJson`');
    }

    // Meta data is not meant to be stored in the cloud as the document values
    jsonCopy.remove(metaName);
    jsonCopy.remove(metaCreateTime);
    jsonCopy.remove(metaUpdateTime);
    jsonCopy.remove(metaCollections);

    final fields = <String, Value>{};

    for (final entry in jsonCopy.entries) {
      fields[entry.key] = valueUtils.fromJsonObject(entry.value);
    }

    final id = (name?.isEmpty ?? true) ? null : pathUtils.name(name);

    return (
      id,
      Document(fields: fields),
    );
  }

  List<JsonObject> _jsonCollectionToDocuments(JsonObject json) {
    final name = json[metaName];
    if (name is! String || name.isEmpty) {
      throw FormatException('Wrong `$metaName` value=`$name` '
          'in json=`$json`');
    }

    final documents = json[metaDocuments];
    if (documents is! List<dynamic>?) {
      throw FormatException('Wrong `$metaDocuments` value=`$documents` '
          'in json=`$json`');
    }

    return (documents ?? []).cast<JsonObject>();
  }

  Future<void> jsonToCollection({
    required String path,
    required JsonObject json,
    required OnParsedCallback onParsed,
    String? changeRootName,
  }) async {
    final collectionName = changeRootName ?? (json[metaName] as String?) ?? '';
    if (collectionName.isEmpty) {
      throw FormatException('Wrong `$metaName` value=`$collectionName` '
          'in json=`$json`');
    }

    final collectionPath = pathUtils.join(
      path,
      collectionName,
    );

    final innerDocuments = _jsonCollectionToDocuments(json);

    for (final innerDocument in innerDocuments) {
      await jsonToDocument(
        path: collectionPath,
        json: innerDocument,
        onParsed: onParsed,
      );
    }
  }
}
