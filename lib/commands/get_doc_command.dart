import 'package:args/command_runner.dart';
import 'package:fs_service/commands/common.dart';
import 'package:fs_service/commands/common_args.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service_lib/data/mappers/document_mapper.dart';
import 'package:fs_service_lib/domain/mappers/value_mapper.dart';
import 'package:fs_service_lib/utils/io_functions.dart';
import 'package:fs_service_lib/utils/json_utils.dart';

class GetDocCommand extends Command<dynamic> {
  GetDocCommand() {
    argAddGeneral(argParser);

    argAddFileOut(argParser, isDocument: true);

    argAddSeparatorOtherSettings(argParser);

    argAddMetaPrefix(argParser);

    argAddValuePrefixes(argParser);
  }

  @override
  final name = 'get-doc';
  @override
  final description = 'Get the document by the path, eg. `col1/doc1`.\n'
      'Command is recursive and will get all nested documents and collections and save them to the output JSON';

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

    checkHaveOnlyOneArg(
      restArgs: restArgs,
      usage: usage,
    );

    final relPath = restArgs.single;

    final docJson = await firestore.getDocument(documentPath: relPath);

    final jsonOut = jsonEncoder.convert(docJson);
    await writeToOut(
      jsonOut,
      fileName: getArgOut(argResults),
    );
  }
}
