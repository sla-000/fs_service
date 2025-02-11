import 'package:fs_service_lib/data/utils/firestore_path_utils.dart';
import 'package:test/test.dart';

void main() {
  final firestorePathUtils = FirestorePathUtils();

  group(
    'FirestorePathUtils tests - ',
    () {
      const projectId = '_projectId';
      const databaseId = '_databaseId';
      const path = '_path';

      setUpAll(() {
        firestorePathUtils.init(
          projectId: projectId,
          databaseId: databaseId,
        );
      });

      test(
        'absolutePathFromRelative tests',
        () {
          expect(
            firestorePathUtils.absolutePathFromRelative(''),
            equals('projects/$projectId/databases/$databaseId/documents'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative('/'),
            equals('projects/$projectId/databases/$databaseId/documents/'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative(' '),
            equals('projects/$projectId/databases/$databaseId/documents'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative(path),
            equals('projects/$projectId/databases/$databaseId/documents/$path'),
          );
        },
      );
    },
  );

  group(
    'FirestorePathUtils tests 2 - ',
    () {
      const projectId = '_projectId';
      const path = '_path';

      setUpAll(() {
        firestorePathUtils.init(projectId: projectId);
      });

      test(
        'absolutePathFromRelative tests',
        () {
          expect(
            firestorePathUtils.absolutePathFromRelative(''),
            equals('projects/$projectId/databases/(default)/documents'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative('/'),
            equals('projects/$projectId/databases/(default)/documents/'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative(' '),
            equals('projects/$projectId/databases/(default)/documents'),
          );

          expect(
            firestorePathUtils.absolutePathFromRelative(path),
            equals('projects/$projectId/databases/(default)/documents/$path'),
          );
        },
      );
    },
  );

  group(
    'FirestorePathUtils tests - ',
    () {
      const projectId = '_projectId';
      const databaseId = '_databaseId';
      const path = '_path';

      setUpAll(() {
        firestorePathUtils.init(
          projectId: projectId,
          databaseId: databaseId,
        );
      });

      test(
        'relativePathFromAbsolute tests',
        () {
          expect(
            firestorePathUtils.relativePathFromAbsolute(
              'projects/$projectId/databases/$databaseId/documents',
            ),
            equals(''),
          );

          expect(
            firestorePathUtils.relativePathFromAbsolute(
              'projects/$projectId/databases/$databaseId/documents/',
            ),
            equals(''),
          );

          expect(
            firestorePathUtils.relativePathFromAbsolute(
              'projects/$projectId/databases/$databaseId/documents/$path',
            ),
            equals(path),
          );
        },
      );
    },
  );
}
