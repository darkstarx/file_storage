This is a simple cross-platform package to operate files in available on a certain platform destinations. Uses idb_shim under the web platform.

## Features

- Provides with destinations of
    - Application's files,
    - Documents,
    - Cache files.
- Recursive creation of folders inside supported destinations.
- Checking existence of a certain file by its path.
- Loading and saving of
    - binary data (`List<int>`),
    - text (utf8-encoded),
    - json objects and arrays.
- Saving stream of data (`List<int>`).

## Usage

```dart
final fileStorage = FileStorage();
final documentsPath = await fileStorage.getDocumentsPath();
final filePath = '$documentsPath/my_folder/my_file.txt';
await fileStorage.ensurePathExists(fileName);
await fileStorage.saveText(fileName, 'My text');
final savedText = await fileStorage.loadText(fileName);
print('Saved text is: $savedText');
final bytes1 = Uint8List.fromList([ 1, 2, 3 ]);
final bytes2 = Uint8List.fromList([ 4, 5, 6 ]);
await fileStorage.saveStream(fileName, Stream.fromIterable([
  bytes1, bytes2
]));
```
