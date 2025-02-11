import 'dart:convert';
import 'dart:io';

import 'package:fs_service_lib/data/mappers/document_mapper.dart';
import 'package:fs_service_lib/domain/mappers/value_mapper.dart';
import 'package:fs_service_lib/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:test/test.dart';

import '../../_utils/document_ext.dart';

void main() {
  final valueUtils = ValueMapper();
  const pathUtils = PathUtils();

  final documentMapper = DocumentMapper(
    valueUtils: valueUtils,
    pathUtils: pathUtils,
  );

  // setUpAll(() {
  //   di.registerLazySingleton<PathUtils>(PathUtils.new);
  // });

  group(
    'DocumentMapper tests 1 - ',
    () {
      const metaPrefix_ = '_metaPrefix_';

      const createTime = '2023-12-28T18:22:54.859008+04:00';
      const updateTime = '2023-12-29T18:22:54.859008+04:00';
      final createTimeUtc =
          DateTime.parse(createTime).toUtc().toIso8601String();
      final updateTimeUtc =
          DateTime.parse(updateTime).toUtc().toIso8601String();

      const name = '_name';

      const bytesPrefix_ = '_bytesPrefix_';
      const locationPrefix_ = '_locationPrefix_';
      const referencePrefix_ = '_referencePrefix_';
      const datetimePrefix_ = '_datetimePrefix_';

      const docPath = '_docPath';
      const colPath = '_colPath';

      setUp(() {
        documentMapper.init(metaPrefix: metaPrefix_);

        valueUtils.init(
          bytesPrefix: bytesPrefix_,
          locationPrefix: locationPrefix_,
          referencePrefix: referencePrefix_,
          datetimePrefix: datetimePrefix_,
        );
      });

      test(
        'documentToJson tests',
        () {
          expect(
            documentMapper.documentToJson(
              Document(
                createTime: createTime,
                updateTime: updateTime,
                name: name,
                fields: {
                  'field1key': Value(stringValue: 'field1val'),
                  'field2key': Value(integerValue: '234412'),
                },
              ),
            ),
            equals(
              {
                'field1key': 'field1val',
                'field2key': 234412,
                '_metaPrefix_name': name,
                '_metaPrefix_createTime': createTimeUtc,
                '_metaPrefix_updateTime': updateTimeUtc,
              },
            ),
          );
        },
      );

      test(
        'collectionToJson tests',
        () {
          expect(
            documentMapper.collectionToJson(
              path: docPath,
              documents: [
                Document(
                  createTime: createTime,
                  updateTime: updateTime,
                  name: name,
                  fields: {
                    'field1key': Value(stringValue: 'field1val'),
                    'field2key': Value(integerValue: '234412'),
                  },
                ),
              ],
            ),
            equals(
              {
                '_metaPrefix_name': docPath,
                '_metaPrefix_documents': [
                  {
                    'field1key': 'field1val',
                    'field2key': 234412,
                    '_metaPrefix_name': name,
                    '_metaPrefix_createTime': createTimeUtc,
                    '_metaPrefix_updateTime': updateTimeUtc,
                  }
                ],
              },
            ),
          );
        },
      );

      test(
        'jsonToDocument tests',
        () async {
          var count = 0;

          Future<void> onParsed(
            String relativePath,
            String? documentId,
            Document document,
          ) async {
            switch (count++) {
              case 0:
                {
                  expect(relativePath, equals(docPath));
                  expect(documentId, equals(name));
                  expect(
                    document.asMap,
                    {
                      'field1key': 'field1val',
                      'field2key': '234412',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 1:
                {
                  fail("Shouldn't fall here");
                }
            }
          }

          await documentMapper.jsonToDocument(
            path: docPath,
            json: {
              'field1key': 'field1val',
              'field2key': 234412,
              '_metaPrefix_name': name,
              '_metaPrefix_createTime': createTimeUtc,
              '_metaPrefix_updateTime': updateTimeUtc,
            },
            onParsed: onParsed,
          );
        },
      );

      test(
        'jsonToCollection tests',
        () async {
          var count = 0;

          Future<void> onParsed(
            String relativePath,
            String? documentId,
            Document document,
          ) async {
            switch (count++) {
              case 0:
                {
                  expect(relativePath, equals('$colPath/$docPath'));
                  expect(documentId, equals(name));

                  expect(
                    document.asMap,
                    {
                      'field1key': 'field1val',
                      'field2key': '234412',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 1:
                {
                  fail("Shouldn't fall here");
                }
            }
          }

          await documentMapper.jsonToCollection(
            path: colPath,
            json: {
              '_metaPrefix_name': docPath,
              '_metaPrefix_documents': [
                {
                  'field1key': 'field1val',
                  'field2key': 234412,
                  '_metaPrefix_name': name,
                  '_metaPrefix_createTime': createTimeUtc,
                  '_metaPrefix_updateTime': updateTimeUtc,
                }
              ],
            },
            onParsed: onParsed,
          );
        },
      );
    },
  );

  group(
    'DocumentMapper tests 2 - ',
    () {
      setUp(() {
        documentMapper.init();

        valueUtils.init();
      });

      test(
        'jsonToDocument tests',
        () async {
          const colPath = '_colPath';

          var count = 0;

          Future<void> onParsed(
            String relativePath,
            String? documentId,
            Document document,
          ) async {
            switch (count++) {
              case 0:
                {
                  expect(relativePath, equals(colPath));
                  expect(documentId, equals('cvbn'));
                  expect(
                    document.asMap,
                    {
                      'someString': 'someStringValue',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 1:
                {
                  expect(relativePath, equals('$colPath/cvbn/test4'));
                  expect(documentId, equals('95il61U47MVonL027u3V'));
                  expect(
                    document.asMap,
                    {
                      'null1': 'NULL_VALUE',
                      'translit': '',
                      'array': '[array1, array2]',
                      'transcript': 'fɔːr',
                      'geopoint': '34.3456/-23.432',
                      'number': '12345',
                      'map': '{key1: {key2: value2}}',
                      'word': 'four',
                      'boolean': 'true',
                      'timestamp': '2023-10-21T11:26:40.152Z',
                      'ref':
                          'projects/ella500/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe',
                      'numberF': '1234.5432',
                      'id': '95il61U47MVonL027u3V',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 2:
                {
                  expect(
                    relativePath,
                    equals('$colPath/cvbn/test4/95il61U47MVonL027u3V/test5'),
                  );
                  expect(documentId, equals('DWtYaWaur4LeTHlnEAIG'));
                  expect(
                    document.asMap,
                    {
                      'test5': 'test5aaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 3:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6',
                    ),
                  );
                  expect(documentId, equals('gmemnkbfMZyo5FmlmakM'));
                  expect(
                    document.asMap,
                    {
                      'test6': 'test6zzz',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 4:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6/gmemnkbfMZyo5FmlmakM/test7',
                    ),
                  );
                  expect(documentId, equals('9DUEUaCeztcCC2lFyzQh'));
                  expect(
                    document.asMap,
                    {
                      'test7': 'test7ccc',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 5:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('HZgbH9j0NRtlX8DglmJZ'));
                  expect(
                    document.asMap,
                    {
                      'test6a3': 'test6aaaa333',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 6:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('bvncvcvcxcv'));
                  expect(
                    document.asMap,
                    {
                      'test6a2': 'test6aaaa2',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 7:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('dfgsrafadfdfsga'));
                  expect(
                    document.asMap,
                    {
                      'test6a': 'test6aaaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 8:
                {
                  expect(relativePath, equals('$colPath/cvbn/test4'));
                  expect(documentId, equals('cvbn'));
                  expect(
                    document.asMap,
                    {
                      'someString': 'someStringValue',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 9:
                {
                  expect(
                    relativePath,
                    equals('$colPath/cvbn/test4/cvbn/test4'),
                  );
                  expect(documentId, equals('95il61U47MVonL027u3V'));
                  expect(
                    document.asMap,
                    {
                      'numberF': '1234.5432',
                      'word': 'four',
                      'id': '95il61U47MVonL027u3V',
                      'array': '[array1, array2]',
                      'timestamp': '2023-10-21T11:26:40.152Z',
                      'null1': 'NULL_VALUE',
                      'translit': '',
                      'number': '12345',
                      'boolean': 'true',
                      'geopoint': '34.3456/-23.432',
                      'ref':
                          'projects/ella500/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe',
                      'map': '{key1: {key2: value2}}',
                      'transcript': 'fɔːr',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 10:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5',
                    ),
                  );
                  expect(documentId, equals('DWtYaWaur4LeTHlnEAIG'));
                  expect(
                    document.asMap,
                    {
                      'test5': 'test5aaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 11:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6',
                    ),
                  );
                  expect(documentId, equals('gmemnkbfMZyo5FmlmakM'));
                  expect(
                    document.asMap,
                    {
                      'test6': 'test6zzz',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 12:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6/gmemnkbfMZyo5FmlmakM/test7',
                    ),
                  );
                  expect(documentId, equals('9DUEUaCeztcCC2lFyzQh'));
                  expect(
                    document.asMap,
                    {
                      'test7': 'test7ccc',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 13:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('bvncvcvcxcv'));
                  expect(
                    document.asMap,
                    {
                      'test6a2': 'test6aaaa2',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 14:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('dfgsrafadfdfsga'));
                  expect(
                    document.asMap,
                    {
                      'test6a': 'test6aaaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 15:
                {
                  expect(
                    relativePath,
                    equals(
                      '$colPath/cvbn/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('qXiWTu99BScZo5Bx5Na5'));
                  expect(
                    document.asMap,
                    {
                      'test6a3': 'test6aaaa333',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              default:
                fail("Shouldn't fall here");
            }
          }

          final docRecursiveStr =
              await File('test/jsons/doc-2.json').readAsString();
          final docRecursiveJson =
              jsonDecode(docRecursiveStr) as Map<String, dynamic>;

          await documentMapper.jsonToDocument(
            path: colPath,
            json: docRecursiveJson,
            onParsed: onParsed,
          );
        },
      );

      test(
        'jsonToCollection tests',
        () async {
          const docPath = '_docPath';

          var count = 0;

          Future<void> onParsed(
            String relativePath,
            String? documentId,
            Document document,
          ) async {
            switch (count++) {
              case 0:
                {
                  expect(relativePath, equals('$docPath/test4'));
                  expect(documentId, equals('95il61U47MVonL027u3V'));
                  expect(
                    document.asMap,
                    {
                      'number': '12345',
                      'array': '[array1, array2]',
                      'boolean': 'true',
                      'word': 'four',
                      'map': '{key1: {key2: value2}}',
                      'translit': '',
                      'null1': 'NULL_VALUE',
                      'geopoint': '34.3456/-23.432',
                      'timestamp': '2023-10-21T11:26:40.152Z',
                      'ref':
                          'projects/ella500/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe',
                      'id': '95il61U47MVonL027u3V',
                      'numberF': '1234.5432',
                      'transcript': 'fɔːr',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 1:
                {
                  expect(
                    relativePath,
                    equals('$docPath/test4/95il61U47MVonL027u3V/test5'),
                  );
                  expect(documentId, equals('DWtYaWaur4LeTHlnEAIG'));
                  expect(
                    document.asMap,
                    {
                      'test5': 'test5aaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 2:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6',
                    ),
                  );
                  expect(documentId, equals('gmemnkbfMZyo5FmlmakM'));
                  expect(
                    document.asMap,
                    {
                      'test6': 'test6zzz',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 3:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6/gmemnkbfMZyo5FmlmakM/test7',
                    ),
                  );
                  expect(documentId, equals('9DUEUaCeztcCC2lFyzQh'));
                  expect(
                    document.asMap,
                    {
                      'test7': 'test7ccc',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 4:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('HZgbH9j0NRtlX8DglmJZ'));
                  expect(
                    document.asMap,
                    {
                      'test6a3': 'test6aaaa333',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 5:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('bvncvcvcxcv'));
                  expect(
                    document.asMap,
                    {
                      'test6a2': 'test6aaaa2',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 6:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('dfgsrafadfdfsga'));
                  expect(
                    document.asMap,
                    {
                      'test6a': 'test6aaaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 7:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4',
                    ),
                  );
                  expect(documentId, equals('cvbn'));
                  expect(
                    document.asMap,
                    {
                      'someString': 'someStringValue',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 8:
                {
                  expect(
                    relativePath,
                    equals('$docPath/test4/cvbn/test4'),
                  );
                  expect(documentId, equals('95il61U47MVonL027u3V'));
                  expect(
                    document.asMap,
                    {
                      'geopoint': '34.3456/-23.432',
                      'boolean': 'true',
                      'numberF': '1234.5432',
                      'translit': '',
                      'number': '12345',
                      'timestamp': '2023-10-21T11:26:40.152Z',
                      'ref':
                          'projects/ella500/databases/(default)/documents/en/YLTunxHK6rgPTWHxjJYe',
                      'id': '95il61U47MVonL027u3V',
                      'map': '{key1: {key2: value2}}',
                      'word': 'four',
                      'array': '[array1, array2]',
                      'transcript': 'fɔːr',
                      'null1': 'NULL_VALUE',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 9:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5',
                    ),
                  );
                  expect(documentId, equals('DWtYaWaur4LeTHlnEAIG'));
                  expect(
                    document.asMap,
                    {
                      'test5': 'test5aaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 10:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6',
                    ),
                  );
                  expect(documentId, equals('gmemnkbfMZyo5FmlmakM'));
                  expect(
                    document.asMap,
                    {
                      'test6': 'test6zzz',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 11:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6/gmemnkbfMZyo5FmlmakM/test7',
                    ),
                  );
                  expect(documentId, equals('9DUEUaCeztcCC2lFyzQh'));
                  expect(
                    document.asMap,
                    {
                      'test7': 'test7ccc',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 12:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('bvncvcvcxcv'));
                  expect(
                    document.asMap,
                    {
                      'test6a2': 'test6aaaa2',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 13:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('dfgsrafadfdfsga'));
                  expect(
                    document.asMap,
                    {
                      'test6a': 'test6aaaa',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              case 14:
                {
                  expect(
                    relativePath,
                    equals(
                      '$docPath/test4/cvbn/test4/95il61U47MVonL027u3V/test5/DWtYaWaur4LeTHlnEAIG/test6a',
                    ),
                  );
                  expect(documentId, equals('qXiWTu99BScZo5Bx5Na5'));
                  expect(
                    document.asMap,
                    {
                      'test6a3': 'test6aaaa333',
                      'name': null,
                      'updateTime': null,
                      'createTime': null,
                    },
                  );
                }

              default:
                fail("Shouldn't fall here");
            }
          }

          final colRecursiveStr =
              await File('test/jsons/col-2.json').readAsString();
          final colRecursiveJson =
              jsonDecode(colRecursiveStr) as Map<String, dynamic>;

          await documentMapper.jsonToCollection(
            path: docPath,
            json: colRecursiveJson,
            onParsed: onParsed,
          );
        },
      );
    },
  );
}
