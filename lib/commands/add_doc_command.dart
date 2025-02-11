import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:fs_service/commands/common.dart';
import 'package:fs_service/commands/common_args.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service_lib/data/mappers/document_mapper.dart';
import 'package:fs_service_lib/domain/mappers/value_mapper.dart';
import 'package:fs_service_lib/domain/repo/easy_firestore.dart';
import 'package:fs_service_lib/utils/io_functions.dart';

class AddDocCommand extends Command<dynamic> {
  AddDocCommand() {
    argAddGeneral(argParser);

    argAddFileIn(argParser, isDocument: true);

    argAddChangeRootName(argParser, isDocument: true);

    argAddSeparatorOtherSettings(argParser);

    argAddMetaPrefix(argParser);

    argAddValuePrefixes(argParser);
  }

  @override
  final name = 'add-doc';
  @override
  final description =
      'Add the document to a collection by the path, eg. `col1/doc1/col2`.\n'
      'Command is recursive and will fill all nested documents and collections as it was in the input JSON';

  @override
  Future<void> run() async {
    di<ValueMapper>().init(
      bytesPrefix: getArgBytesPrefix(argResults),
      locationPrefix: getArgLocationPrefix(argResults),
      referencePrefix: getArgReferencePrefix(argResults),
      datetimePrefix: getArgDateTimePrefix(argResults),
    );

    di<DocumentMapper>().init(metaPrefix: getArgMetaPrefix(argResults));

    final firestore = await initFirestore(
      project: getArgProject(argResults),
      database: getArgDatabase(argResults),
      usage: usage,
    );

    final restArgs = argResults!.rest;

    if (restArgs.isEmpty) {
      throw UsageException('Command must have an argument', usage);
    } else if (restArgs.length > 1) {
      throw UsageException('Command must have only one argument', usage);
    }

    final relPath = restArgs.single;

    final jsonIn = await readFromIn(fileName: getArgIn(argResults));

    final jsonObject = jsonDecode(jsonIn);
    if (jsonObject is! JsonObject) {
      throw UsageException(
        '''
Input JSON must have an Object format.
More about the Object format here: https://datatracker.ietf.org/doc/html/rfc8259#section-4
''',
        usage,
      );
    }

    await firestore.addDocument(
      collectionPath: relPath,
      json: jsonObject,
      changeRootName: getArgChangeRootName(argResults),
    );
  }
}
