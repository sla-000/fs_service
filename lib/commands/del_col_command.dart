import 'package:args/command_runner.dart';
import 'package:fs_service/commands/common.dart';
import 'package:fs_service/commands/common_args.dart';

class DelColCommand extends Command<dynamic> {
  DelColCommand() {
    argAddGeneral(argParser);

    argAddSeparatorOtherSettings(argParser);
  }

  @override
  final name = 'del-col';
  @override
  final description =
      'Delete the collection by the path, eg. `col1/doc1/col2`.\n'
      'Command is recursive and will delete all nested documents and collections forever';

  @override
  Future<void> run() async {
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

    await firestore.deleteCollection(collectionPath: relPath);
  }
}
