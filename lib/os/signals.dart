import 'dart:async';
import 'dart:io';

import 'package:fs_service/log/log.dart';
import 'package:fs_service/os/close_app.dart';

void setupOsSignals() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    try {
      ProcessSignal.sigint.watch().listen((event) {
        log.info('setupOsSignals: sigint, event=$event');
        unawaited(closeApp(ExitCode.sigint));
      });
    } on Exception catch (error) {
      log.fine('setupOsSignals: sigint', error);
    }
  }

  if (Platform.isLinux || Platform.isMacOS) {
    try {
      ProcessSignal.sigkill.watch().listen((event) {
        log.info('setupOsSignals: sigkill, event=$event');
        unawaited(closeApp(ExitCode.sigkill));
      });
    } on Exception catch (error) {
      log.fine('setupOsSignals: sigkill', error);
    }
  }

  if (Platform.isLinux) {
    try {
      ProcessSignal.sigterm.watch().listen((event) {
        log.info('setupOsSignals: sigterm, event=$event');
        unawaited(closeApp(ExitCode.sigterm));
      });
    } on Exception catch (error) {
      log.fine('setupOsSignals: sigterm', error);
    }
  }
}
