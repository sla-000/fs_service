import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import 'package:args/command_runner.dart';
import 'package:fs_service/commands/add_col_command.dart';
import 'package:fs_service/commands/add_doc_command.dart';
import 'package:fs_service/commands/del_col_command.dart';
import 'package:fs_service/commands/del_doc_command.dart';
import 'package:fs_service/commands/get_col_command.dart';
import 'package:fs_service/commands/get_doc_command.dart';
import 'package:fs_service/commands/log_level.dart';
import 'package:fs_service/log/log.dart';
import 'package:fs_service/os/close_app.dart';

Future<void> app(List<String> args) async {
  final runner = CommandRunner(
    'fs_service',
    'Tool for importing and exporting Firestore data with service account',
  )
    ..addCommand(GetDocCommand())
    ..addCommand(GetColCommand())
    ..addCommand(AddDocCommand())
    ..addCommand(AddColCommand())
    ..addCommand(DelDocCommand())
    ..addCommand(DelColCommand());

  addLogLevelArg(runner.argParser);

  try {
    await runner.run(args);
  } on UsageException catch (error, stackTrace) {
    log.info('UsageException', error, stackTrace);
    stdout.writeln('\nError: $error');

    await closeApp(ExitCode.args);
    // ignore: avoid_catching_errors
  } on ArgumentError catch (error, stackTrace) {
    log.info('ArgumentError', error, stackTrace);
    stdout.writeln('\nError: $error');

    stdout.writeln('\n${runner.usage}');

    await closeApp(ExitCode.args);
  } on DetailedApiRequestError catch (error, stackTrace) {
    log.info('${error.runtimeType}', error, stackTrace);
    stdout.writeln('\nError: $error');

    switch (error.status) {
      case 400:
        stdout.writeln('\nAre you sure you are not trying to apply '
            'document command to collection or vice-versa?');

      case 409:
        stdout.writeln('\nLooks like document or collection already exists, '
            'unable to overwrite');
    }

    await closeApp(ExitCode.args);
  }
}
