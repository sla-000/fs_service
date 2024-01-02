import 'package:args/args.dart';

const argNameProject = 'project';
const argNameDatabase = 'database';

const argNameOut = 'out-file';
const argNameIn = 'in-file';

const argNameChangeRootName = 'change-name';

const argNameMetaPrefix = 'meta-prefix';
const argNameReferencePrefix = 'reference-prefix';
const argNameLocationPrefix = 'location-prefix';
const argNameBytesPrefix = 'bytes-prefix';
const argNameDateTimePrefix = 'datetime-prefix';

void argAddGeneral(ArgParser argParser) {
  argParser.addSeparator('General settings');
  argParser.addOption(
    argNameProject,
    abbr: 'p',
    mandatory: true,
    valueHelp: 'myProject',
    help: 'Name of your project in the firebase console',
  );
  argParser.addOption(
    argNameDatabase,
    defaultsTo: '(default)',
    valueHelp: 'myDatabase',
    help: 'Name of the database of your project in the firebase console',
  );
}

void argAddFileOut(
  ArgParser argParser, {
  required bool isDocument,
}) {
  argParser.addSeparator('IO settings');
  argParser.addOption(
    argNameOut,
    abbr: 'o',
    valueHelp: 'downloaded_${_resourceType(isDocument)}.json',
    help: 'Path of the output file where the ${_resourceType(isDocument)} '
        'JSON will be written. If omitted, STDOUT will be used.',
  );
}

void argAddFileIn(
  ArgParser argParser, {
  required bool isDocument,
}) {
  argParser.addSeparator('IO settings');
  argParser.addOption(
    argNameIn,
    abbr: 'i',
    valueHelp: '${_resourceType(isDocument)}_to_upload.json',
    help: 'Path of the input file with the ${_resourceType(isDocument)} JSON. '
        'If omitted, STDIN will be used',
  );
}

void argAddSeparatorOtherSettings(ArgParser argParser) =>
    argParser.addSeparator('Other settings');

void argAddMetaPrefix(ArgParser argParser) {
  argParser.addSeparator('JSON meta-data prefix settings');
  argParser.addOption(
    argNameMetaPrefix,
    defaultsTo: r'$',
    valueHelp: 'myPrefix',
    help: "Prefix for meta-data names.\n"
        "Meta-data is not an actual data included to your documents or collections. "
        "It's a data that will help the tool to work with the data fields of the documents.\n"
        r"By default meta-data name is started with `$` sign, "
        "but if it clashes with your field names you can change it to "
        "e.g. `@` or any other suitable for you values",
  );
}

void argAddValuePrefixes(ArgParser argParser) {
  argParser.addSeparator('Value special prefixes settings');
  _argAddReferencePrefix(argParser);
  _argAddLocationPrefix(argParser);
  _argAddBytesPrefix(argParser);
  _argAddDateTimePrefix(argParser);
}

void _argAddReferencePrefix(ArgParser argParser) => argParser.addOption(
      argNameReferencePrefix,
      defaultsTo: 'reference://',
      valueHelp: 'myRefPrefix',
      help: 'Prefix for reference value.\n'
          'This prefix is used to (de)serialize data of your `reference` field correctly',
    );

void _argAddLocationPrefix(ArgParser argParser) => argParser.addOption(
      argNameLocationPrefix,
      defaultsTo: 'location://',
      valueHelp: 'myLocPrefix',
      help: 'Prefix for location value.\n'
          'This prefix is used to (de)serialize data of your `location` field correctly',
    );

void _argAddBytesPrefix(ArgParser argParser) => argParser.addOption(
      argNameBytesPrefix,
      defaultsTo: 'bytes://',
      valueHelp: 'myBytesPrefix',
      help: 'Prefix for bytes value.\n'
          'This prefix is used to (de)serialize data of your `bytes` field correctly',
    );

void _argAddDateTimePrefix(ArgParser argParser) => argParser.addOption(
      argNameDateTimePrefix,
      defaultsTo: 'datetime://',
      valueHelp: 'myDatePrefix',
      help: 'Prefix for datetime value.\n'
          'This prefix is used to (de)serialize data of your `datetime` field correctly',
    );

void argAddChangeRootName(
  ArgParser argParser, {
  required bool isDocument,
}) =>
    argParser.addOption(
      argNameChangeRootName,
      abbr: 'c',
      valueHelp: 'new ${_resourceType(isDocument)} root name',
      help: 'Change the root ${_resourceType(isDocument)} name.\n'
          'The name of the ${_resourceType(isDocument)} is stored in the `\$name` '
          'meta-data of your root json ${_resourceType(isDocument)} object. '
          'You can change this name when sending the ${_resourceType(isDocument)} '
          'to the firestore',
    );

String _resourceType(bool isDocument) => isDocument ? 'document' : 'collection';

String getArgProject(ArgResults? argResults) =>
    argResults![argNameProject] as String;

String getArgDatabase(ArgResults? argResults) =>
    argResults![argNameDatabase] as String;

String? getArgOut(ArgResults? argResults) => argResults![argNameOut] as String?;

String? getArgIn(ArgResults? argResults) => argResults![argNameIn] as String?;

String? getArgMetaPrefix(ArgResults? argResults) =>
    argResults![argNameMetaPrefix] as String?;

String? getArgReferencePrefix(ArgResults? argResults) =>
    argResults![argNameReferencePrefix] as String?;

String? getArgLocationPrefix(ArgResults? argResults) =>
    argResults![argNameLocationPrefix] as String?;

String? getArgBytesPrefix(ArgResults? argResults) =>
    argResults![argNameBytesPrefix] as String?;

String? getArgDateTimePrefix(ArgResults? argResults) =>
    argResults![argNameDateTimePrefix] as String?;

String? getArgChangeRootName(ArgResults? argResults) =>
    argResults![argNameChangeRootName] as String?;
