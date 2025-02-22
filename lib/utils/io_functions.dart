import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String> readFromIn({
  String? fileName,
}) async {
  late final String jsonIn;

  if (fileName != null) {
    final file = File(fileName);
    jsonIn = await file.readAsString();
  } else {
    jsonIn = await stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .join('\n');
  }

  return jsonIn;
}

Future<void> writeToOut(
  String jsonStr, {
  String? fileName,
}) async {
  if (fileName != null) {
    final file = await File(fileName).create(recursive: true);
    await file.writeAsString(jsonStr);
  } else {
    stdout.writeln(jsonStr);
  }
}
