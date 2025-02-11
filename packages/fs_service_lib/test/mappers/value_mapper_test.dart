import 'package:googleapis/firestore/v1.dart';
import 'package:test/test.dart';

import '../../lib/domain/mappers/value_mapper.dart';

const _bytesPrefix = '_bytesPrefix';
const _locationPrefix = '_locationPrefix';
const _referencePrefix = '_referencePrefix';
const _datetimePrefix = '_datetimePrefix';

const _double = -234.456e5;

const _latitude = -123.4567;
const _longitude = 12.3456;

const _int = -756746312;

const _reference = 'asd/fgh/jkl';

const _string = '_string';

const _localDatetime = '2023-12-28T09:16:55.736885+04:00';
const _utcDatetime = '2023-12-28T05:16:55.736885Z';

const _base64 = 'dGVzdA==';

void main() {
  final valueMapper = ValueMapper();

  setUp(() {
    valueMapper.init(
      bytesPrefix: _bytesPrefix,
      locationPrefix: _locationPrefix,
      referencePrefix: _referencePrefix,
      datetimePrefix: _datetimePrefix,
    );
  });

  group(
    'ValueMapper tests - ',
    () {
      test(
        'toJsonObject tests',
        () {
          expect(
            valueMapper.toJsonObject(
              Value(
                arrayValue: ArrayValue(
                  values: [
                    Value(stringValue: 'a'),
                    Value(stringValue: 'b'),
                    Value(stringValue: 'c'),
                  ],
                ),
              ),
            ),
            equals(['a', 'b', 'c']),
          );

          expect(
            valueMapper.toJsonObject(Value(booleanValue: true)),
            equals(true),
          );

          expect(
            valueMapper.toJsonObject(Value(bytesValue: _base64)),
            equals('$_bytesPrefix$_base64'),
          );

          expect(
            valueMapper.toJsonObject(Value(doubleValue: _double)),
            equals(_double),
          );

          expect(
            valueMapper.toJsonObject(
              Value(
                geoPointValue: LatLng(
                  latitude: _latitude,
                  longitude: _longitude,
                ),
              ),
            ),
            equals('$_locationPrefix$_latitude/$_longitude'),
          );

          expect(
            valueMapper.toJsonObject(Value(integerValue: _int.toString())),
            equals(_int),
          );

          expect(
            valueMapper.toJsonObject(
              Value(
                mapValue: MapValue(
                  fields: {
                    'str1Key': Value(stringValue: 'str1Val'),
                    'int1Key': Value(integerValue: '456334'),
                  },
                ),
              ),
            ),
            equals({
              'str1Key': 'str1Val',
              'int1Key': 456334,
            }),
          );

          expect(
            valueMapper.toJsonObject(Value(nullValue: 'NULL_VALUE')),
            equals(null),
          );

          expect(
            valueMapper.toJsonObject(Value(referenceValue: 'asd/fgh/jkl')),
            equals('$_referencePrefix$_reference'),
          );

          expect(
            valueMapper.toJsonObject(Value(stringValue: _string)),
            equals(_string),
          );
        },
      );

      test(
        'fromJsonObject tests',
        () {
          late Value value;

          value = valueMapper.fromJsonObject(['a', 'b', 'c']);
          expect(value.arrayValue!.values![0].stringValue, 'a');
          expect(value.arrayValue!.values![1].stringValue, 'b');
          expect(value.arrayValue!.values![2].stringValue, 'c');

          value = valueMapper.fromJsonObject(true);
          expect(value.booleanValue, equals(true));

          value = valueMapper.fromJsonObject('$_bytesPrefix$_base64');
          expect(value.bytesValue, equals(_base64));

          value = valueMapper.fromJsonObject(_double);
          expect(value.doubleValue, equals(_double));

          value = valueMapper
              .fromJsonObject('$_locationPrefix$_latitude/$_longitude');
          expect(value.geoPointValue!.latitude, equals(_latitude));
          expect(value.geoPointValue!.longitude, equals(_longitude));

          value = valueMapper.fromJsonObject(_int);
          expect(value.integerValue, equals(_int.toString()));

          value = valueMapper.fromJsonObject({
            'str1Key': 'str1Val',
            'int1Key': 456334,
          });
          expect(
            value.mapValue!.fields!['str1Key']!.stringValue,
            equals('str1Val'),
          );
          expect(
            value.mapValue!.fields!['int1Key']!.integerValue,
            equals('456334'),
          );

          value = valueMapper.fromJsonObject('NULL_VALUE');
          expect(value.nullValue, equals(null));

          value = valueMapper.fromJsonObject('$_referencePrefix$_reference');
          expect(value.referenceValue, equals('asd/fgh/jkl'));

          value = valueMapper.fromJsonObject(_string);
          expect(value.stringValue, equals(_string));
        },
      );

      test(
        'timestampValue tests',
        () {
          expect(
            valueMapper.toJsonObject(Value(timestampValue: _utcDatetime)),
            equals('$_datetimePrefix$_utcDatetime'),
          );

          expect(
            valueMapper.toJsonObject(Value(timestampValue: _localDatetime)),
            equals('$_datetimePrefix$_utcDatetime'),
          );

          late Value value;
          late String datetime;

          datetime = DateTime.parse(_localDatetime).toIso8601String();
          value = valueMapper.fromJsonObject('$_datetimePrefix$datetime');
          expect(value.timestampValue, equals(_utcDatetime));

          datetime = DateTime.parse(_utcDatetime).toIso8601String();
          value = valueMapper.fromJsonObject('$_datetimePrefix$datetime');
          expect(value.timestampValue, equals(_utcDatetime));
        },
      );
    },
  );
}
