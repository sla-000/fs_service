import 'package:googleapis/firestore/v1.dart';

import 'value_ext.dart';

extension DocumentTestExt on Document {
  Map<String, dynamic> get asMap {
    final result = <String, dynamic>{};

    final convertedMap = fields?.map(
      (key, value) => MapEntry(key, value.asString),
    );
    if (convertedMap != null) {
      result.addAll(convertedMap);
    }

    result['name'] = name;
    result['updateTime'] = updateTime;
    result['createTime'] = createTime;

    return result;
  }
}
