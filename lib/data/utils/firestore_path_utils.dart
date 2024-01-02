class FirestorePathUtils {
  FirestorePathUtils();

  late String _projectId;
  late String _databaseId;

  void init({
    required String projectId,
    String databaseId = '(default)',
  }) {
    _projectId = projectId;
    _databaseId = databaseId;
  }

  String absolutePathFromRelative(String relativePath) {
    final path = relativePath.trim();

    if (path.isEmpty || path.startsWith('/')) {
      return '$rootPath'
          '$path';
    } else {
      return '$rootPath'
          '/'
          '$path';
    }
  }

  String relativePathFromAbsolute(String absolutePath) {
    final segments = absolutePath.split(
      RegExp('^$rootPath/'),
    );

    if (segments.length < 2) {
      return '';
    }

    return segments[1];
  }

  String get rootPath =>
      'projects/$_projectId/databases/$_databaseId/documents';
}
