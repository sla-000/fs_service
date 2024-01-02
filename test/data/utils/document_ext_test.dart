import 'package:fs_service/data/utils/document_ext.dart';
import 'package:fs_service/di/di.dart';
import 'package:fs_service/utils/path_utils.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockPathUtils extends Mock implements PathUtils {}

final _mockPathUtils = _MockPathUtils();

const _name = '_name';
const _nameFromPathUtils = '_nameFromPathUtils';

void main() {
  group(
    'DocumentExt tests - ',
    () {
      setUpAll(() {
        di.registerLazySingleton<PathUtils>(() => _mockPathUtils);
      });

      test(
        'id  tests',
        () {
          when(() => _mockPathUtils.name(any())).thenReturn(_nameFromPathUtils);

          expect(Document().id, equals(null));

          expect(Document(name: _name).id, equals(_nameFromPathUtils));
        },
      );
    },
  );
}
