import 'dart:async';
import 'dart:convert';

import 'package:idb_shim/idb_browser.dart';

import 'platformed.dart';


FileStorage createFileStorage() => FileStorageWeb();


class FileStorageWeb implements FileStorage
{
  static const storeName = 'filestorage';
  static const filesPath = 'common';
  static const documentsPath = 'documents';
  static const cachePath = 'cache';

  @override
  Future<String> getFilesPath({
    final String? path,
    final String? profile,
    final bool create = false,
  }) => _buildPath(filesPath,
    path: path,
    profile: profile,
  );

  @override
  Future<String> getDocumentsPath({
    final String? path,
    final String? profile,
    final bool create = false,
  }) => _buildPath(documentsPath,
    path: path,
    profile: profile,
  );

  @override
  Future<String> getCachePath({
    final String? path,
    final String? profile,
    final bool create = false,
  }) => _buildPath(cachePath,
    path: path,
    profile: profile,
  );

  @override
  Future<void> ensurePathExists(final String fileName) async
  {
  }

  @override
  Future<bool> fileExists(final String fileName) async
  {
    final db = await _getDatabase();
    final transaction = db.transaction([ storeName ], idbModeReadOnly);
    final store = transaction.objectStore(storeName);
    final count = await store.count(fileName);
    return count > 0;
  }

  @override
  Future<List<int>?> loadData(final String fileName) async
  {
    final db = await _getDatabase();
    final transaction = db.transaction([ storeName ], idbModeReadOnly);
    final store = transaction.objectStore(storeName);
    final data = await store.getObject(fileName);
    if (data == null) return null;
    if (data is !List<int>) return null;
    return data;
  }

  @override
  Future<String?> loadText(final String fileName) async
  {
    final data = await loadData(fileName);
    if (data == null) return null;
    return utf8.decode(data);
  }

  @override
  Future<Object?> loadJson(final String fileName) async
  {
    final data = await loadData(fileName);
    if (data == null || data.isEmpty) return null;
    final objects = await Stream.value(data)
      .transform(utf8.decoder)
      .transform(json.decoder)
      .toList();
    return objects.isEmpty ? null : objects.first;
  }

  @override
  Future<void> saveData(final String fileName, final List<int> data) async
  {
    final db = await _getDatabase();
    final transaction = db.transaction([ storeName ], idbModeReadWrite);
    final store = transaction.objectStore(storeName);
    await store.put(data, fileName);
  }

  @override
  Future<void> saveText(final String fileName, final String text)
  {
    return saveData(fileName, utf8.encode(text));
  }

  @override
  Future<void> saveJson(final String fileName, final dynamic jsonValue, {
    Object? Function(dynamic)? toEncodable,
  })
  {
    final stream = Stream.value(jsonValue)
      .transform(JsonEncoder(toEncodable))
      .transform(const Utf8Encoder());
    return saveStream(fileName, stream);
  }

  @override
  Future<void> saveStream(
    final String fileName,
    final Stream<List<int>> stream,
  ) async
  {
    final data = (await stream.toList()).expand((e) => e).toList();
    await saveData(fileName, data);
  }

  @override
  Future<void> removeFile(final String fileName) async
  {
    final db = await _getDatabase();
    final transaction = db.transaction([ storeName ], idbModeReadWrite);
    final store = transaction.objectStore(storeName);
    await store.delete(fileName);
  }

  Future<String> _buildPath(final String basePath, {
    final String? path,
    final String? profile,
  }) async
  {
    var fullPath = basePath;
    if (profile != null && profile.isNotEmpty) {
      fullPath += '/$profile';
    }
    if (path != null && path.isNotEmpty) {
      fullPath += '/$path';
    }
    return fullPath;
  }

  Future<Database> _getDatabase() async
  {
    _database ??= await idbFactoryNative.open('filestorage.db',
      version: 1,
      onUpgradeNeeded: _onUpgradeNeeded,
      onBlocked: _onBlocked,
    );
    return _database!;
  }

  FutureOr<void> _onUpgradeNeeded(final VersionChangeEvent event)
  {
    for (var v = event.oldVersion + 1; v <= event.newVersion; ++v) {
      switch (v) {
        case 1: _upgradeToVersion1(event.database);
        default:
          throw UnimplementedError(
            'Migration the database to version $v is not implemented'
          );
      }
    }
  }

  void _upgradeToVersion1(final Database database)
  {
    database.createObjectStore(storeName);
  }

  void _onBlocked(final Event event)
  {
    _database?.close();
    _database = null;
  }

  Database? _database;
}
