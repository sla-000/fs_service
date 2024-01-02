import 'package:fs_service/di/di.dart';
import 'package:fs_service/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';

extension DocumentExt on Document {
  /// Get document Id
  String? get id => name != null ? di<PathUtils>().name(name) : null;
}
