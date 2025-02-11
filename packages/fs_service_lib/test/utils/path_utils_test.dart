import 'package:test/test.dart';

import '../../lib/utils/path_utils.dart';

void main() {
  const pathUtils = PathUtils();

  group(
    'PathUtils tests - ',
    () {
      group(
        'name tests - ',
        () {
          const name = '_name';

          test(
            'name tests',
            () {
              expect(
                pathUtils.name(
                  'projects/projectId/databases/databaseId/documents/$name',
                ),
                equals(name),
              );

              expect(
                pathUtils.name(
                  'projects/projectId/databases/databaseId/documents/$name ',
                ),
                equals(name),
              );

              expect(
                pathUtils.name(
                  'projects/projectId/databases/databaseId/documents/',
                ),
                equals(''),
              );

              expect(
                pathUtils.name(
                  'projects/projectId/databases/databaseId/documents/ ',
                ),
                equals(''),
              );
            },
          );
        },
      );

      group(
        'parent tests - ',
        () {
          const path = 'projects/projectId/databases/databaseId/documents';

          test(
            'name tests',
            () {
              expect(
                pathUtils.parent('$path/qwer'),
                equals(path),
              );

              expect(
                pathUtils.parent('$path/ '),
                equals(path),
              );

              expect(
                pathUtils.parent('$path/'),
                equals(path),
              );
            },
          );
        },
      );

      group(
        'join tests - ',
        () {
          test(
            'name tests',
            () {
              expect(
                pathUtils.join('path1', 'path2'),
                equals('path1/path2'),
              );

              expect(
                pathUtils.join('path1', ''),
                equals('path1'),
              );
              expect(
                pathUtils.join('path1', null),
                equals('path1'),
              );

              expect(
                pathUtils.join('', 'path2'),
                equals('path2'),
              );
              expect(
                pathUtils.join(null, 'path2'),
                equals('path2'),
              );

              expect(
                pathUtils.join('', ''),
                equals(''),
              );
              expect(
                pathUtils.join(null, null),
                equals(''),
              );
            },
          );
        },
      );
    },
  );
}
