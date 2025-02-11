class PathUtils {
  const PathUtils();

  String parent(String? resourcePath) {
    if (resourcePath?.isEmpty ?? true) {
      return '';
    }

    final pathSegments = resourcePath!.split('/');
    pathSegments.removeLast();

    return pathSegments.join('/');
  }

  String name(String? resourcePath) {
    if (resourcePath?.isEmpty ?? true) {
      return '';
    }

    final pathSegments = resourcePath!.split('/');
    return pathSegments.last.trim();
  }

  String join(String? path1, String? path2) {
    final $path1 = path1 ?? '';
    final $path2 = path2 ?? '';

    if ($path1.isEmpty) {
      return $path2;
    }

    if ($path2.isEmpty) {
      return $path1;
    }

    return '$path1/$path2';
  }
}
