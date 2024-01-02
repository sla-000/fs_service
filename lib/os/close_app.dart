import 'dart:async';
import 'dart:io';

import 'package:fs_service/di/di.dart';

enum ExitCode {
  /// Normal exit
  ok,

  /// Wrong args
  args,

  /// Some error
  error,

  /// Caught SIGINT
  sigint,

  /// Caught SIGKILL
  sigkill,

  /// Caught SIGTERM
  sigterm,
}

Future<void> closeApp(ExitCode exitCode) async {
  di.dispose().ignore();

  exit(exitCode.index);
}
