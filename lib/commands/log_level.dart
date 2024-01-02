import 'package:args/args.dart';
import 'package:fs_service/log/log.dart';
import 'package:logging/logging.dart';

const kLogLevelTrace = 'trace';
const kLogLevelInfo = 'info';
const _kLogLevelSevere = 'severe';

const kLogLevelDefault = _kLogLevelSevere;

const argToLogLevelMap = {
  kLogLevelTrace: Level.FINE,
  kLogLevelInfo: Level.INFO,
  _kLogLevelSevere: Level.SEVERE,
};

void addLogLevelArg(ArgParser argParser) {
  argParser.addOption(
    'verbose',
    abbr: 'v',
    help: 'Logging level. Messages are printed to stderr. '
        'Severe failures are always printed',
    defaultsTo: kLogLevelDefault,
    allowedHelp: {
      kLogLevelTrace: 'Trace all activity',
      kLogLevelInfo: 'Detailed errors info',
    },
    allowed: [
      kLogLevelTrace,
      kLogLevelInfo,
    ],
    callback: (option) => log.level = argToLogLevelMap[option],
  );
}
