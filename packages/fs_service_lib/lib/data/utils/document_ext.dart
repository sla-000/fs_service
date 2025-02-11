import 'package:fs_service_lib/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';

extension DocumentExt on Document {
  /// Get document Id
  String? id(PathUtils pathUtils) => name != null ? pathUtils.name(name) : null;
}
