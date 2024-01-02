import 'dart:io';

import 'package:logging/logging.dart';

Logger get log => Logger.root;

void logInit([Level? level]) {
  Logger.root.level = level ?? Level.ALL;

  Logger.root.onRecord.listen((record) {
    var error = '';
    if (record.error != null) {
      error = '${record.error}';

      if (record.stackTrace != null) {
        error = '${record.error}\n${record.stackTrace}';
      }
    }

    stderr.writeln('''
${record.time}/${record.level.name}: ${record.message}
$error
''');
  });
}
