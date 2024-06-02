import 'unsupported.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart';


abstract interface class FileStorage
{
  /// Creates a platform specific instance of the [FileStorage].
  factory FileStorage() => createFileStorage();

  /// Returns the path to application's file in the local storage.
  Future<String> getFilesPath({
    final String? path,
    final String? profile,
    final bool create = false,
  });

  /// Returns the path to application's documents in the local storage.
  Future<String> getDocumentsPath({
    final String? path,
    final String? profile,
    final bool create = false,
  });

  /// Returns the path to application's cache in the local storage.
  ///
  /// This is the path to the temporary files. Cached files can be deleted by
  /// the platform at any time.
  Future<String> getCachePath({
    final String? path,
    final String? profile,
    final bool create = false,
  });

  /// Checks recursively that all folders on the [fileName]'s path exist, if any
  /// folder doesn't exist, it will be created.
  Future<void> ensurePathExists(final String fileName);

  /// Checks whether the file with specified [fileName] exists.
  Future<bool> fileExists(final String fileName);

  /// Loads the data from the file [fileName].
  Future<List<int>?> loadData(final String fileName);

  /// Reads the text encoded in UTF-8 from the file [fileName].
  Future<String?> loadText(final String fileName);

  /// Reads the json encoded in UTF-8 from the file [fileName].
  Future<Object?> loadJson(final String fileName);

  /// Saves the [data] to the file [fileName].
  Future<bool> saveData(final String fileName, final List<int> data);

  /// Saves the [text] to the file [fileName].
  Future<bool> saveText(final String fileName, final String text);

  /// Saves the [jsonValue] to the file [fileName].
  ///
  /// If [toEncodable] is provided, it's used during serialization the
  /// [jsonValue].
  Future<bool> saveJson(final String fileName, final dynamic jsonValue, {
    Object? Function(dynamic)? toEncodable,
  });

  /// Saves the [stream] to the file [fileName].
  Future<bool> saveStream(final String fileName, final Stream<List<int>> stream);

  /// Removes the file with the name [fileName] if exists.
  Future<void> removeFile(final String fileName);
}
