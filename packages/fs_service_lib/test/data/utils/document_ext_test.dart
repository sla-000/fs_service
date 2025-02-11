import 'package:fs_service_lib/data/utils/document_ext.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../lib/utils/path_utils.dart';

class _MockPathUtils extends Mock implements PathUtils {}

final _mockPathUtils = _MockPathUtils();

const _name = '_name';
const _nameFromPathUtils = '_nameFromPathUtils';

void main() {
  group(
    'DocumentExt tests - ',
    () {
      // setUpAll(() {
      //   di.registerLazySingleton<PathUtils>(() => _mockPathUtils);
      // });

      test(
        'id  tests',
        () {
          when(() => _mockPathUtils.name(any())).thenReturn(_nameFromPathUtils);

          expect(Document().id(_mockPathUtils), equals(null));

          expect(
            Document(name: _name).id(_mockPathUtils),
            equals(_nameFromPathUtils),
          );
        },
      );
    },
  );
}
