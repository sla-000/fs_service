import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service/log/log.dart';
import 'package:fs_service_lib/domain/repo/easy_firestore.dart';

const kFirestoreCredentialsHelpUrl =
    'https://cloud.google.com/docs/authentication/application-default-credentials#GAC';

Future<FirestoreRepo> initFirestore({
  required String project,
  required String database,
  required String usage,
}) async {
  final firestore = di<FirestoreRepo>();

  try {
    await firestore.init(projectId: project, databaseId: database);
  } on Exception catch (error, stackTrace) {
    log.info('Firestore init error=$error', stackTrace);

    final envVars = Platform.environment;
    final credentialsFile = envVars['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credentialsFile == null || credentialsFile.isEmpty) {
      throw UsageException(
        '''
Have you forgotten to set the GOOGLE_APPLICATION_CREDENTIALS environment variable?

More about here: $kFirestoreCredentialsHelpUrl''',
        '',
      );
    } else {
      throw UsageException(
        '''
Check your internet connection or credentials file

More about credentials file: $kFirestoreCredentialsHelpUrl''',
        '',
      );
    }
  }

  return firestore;
}

void checkHaveOnlyOneArg({
  required List<String> restArgs,
  required String usage,
}) {
  if (restArgs.isEmpty) {
    throw UsageException('Command must have an argument', usage);
  } else if (restArgs.length > 1) {
    throw UsageException('Command must have only one argument', usage);
  }
}
