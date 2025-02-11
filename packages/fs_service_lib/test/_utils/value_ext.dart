import 'package:googleapis/firestore/v1.dart';

extension ValueExt on Value {
  String get asString {
    final value = toJson().values.single;

    switch (value) {
      case final LatLng latLng:
        return '${latLng.latitude}/${latLng.longitude}';

      case final ArrayValue arrayVal:
        return arrayVal.values!.map((e) => e.asString).toList().toString();

      case final MapValue mapValue:
        return mapValue.fields!
            .map((key, value) => MapEntry(key, value.asString))
            .toString();
    }

    return value.toString();
  }
}
