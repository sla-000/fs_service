import 'dart:async';

import 'package:fs_service/app.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service/log/log.dart';
import 'package:fs_service/os/close_app.dart';
import 'package:fs_service/os/signals.dart';

Future<void> main(List<String> args) async {
  di.init();

  setupOsSignals();

  logInit();

  await runZonedGuarded(
    () async {
      await app(args);
    },
    (error, stack) async {
      log.shout(
        'Application error, please save following text and file a bug:\n',
        error,
        stack,
      );

      di.dispose().ignore();
      await closeApp(ExitCode.error);
    },
  );

  di.dispose().ignore();
  await closeApp(ExitCode.ok);
}
