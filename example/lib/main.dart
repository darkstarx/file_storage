import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  String get appFilesPath => _appFilesPath ?? '';
  String get docsFilesPath => _docsFilesPath ?? '';
  String get cacheFilesPath => _cacheFilesPath ?? '';
  String get destination => _destination ?? '';
  String get fileName => '$destination/${_fileNameController.text}';

  @override
  void initState()
  {
    super.initState();
    _fileNameController = TextEditingController(text: 'my_files/my_text.txt');
    _textController = TextEditingController();
    _initPaths();
  }

  @override
  void dispose()
  {
    _textController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    const pathNames = [ 'App files', 'Documents', 'Cache' ];
    const padding = 8.0;
    final paths = [ appFilesPath, docsFilesPath, cacheFilesPath ];
    final tabSize = (MediaQuery.sizeOf(context).width - padding * 2)
      / paths.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Destination:',
              ),
              child: ToggleButtons(
                isSelected: paths.map((p) => _destination == p).toList(),
                onPressed: (i) => setState(() => _destination = paths[i]),
                children: pathNames.map((n) => SizedBox(
                  width: tabSize.floorToDouble(),
                  child: Center(child: Text(n)),
                )).toList(),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'File name:',
              ),
              controller: _fileNameController,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) => value == null || value.isEmpty
                ? 'Enter the file name'
                : null,
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Text in the file:',
                helperText: 'Press Load or change the text and press Save.'
              ),
              controller: _textController,
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Load'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _fileNameController.text.isEmpty ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initPaths() async
  {
    final appFilesPath = await _fileStorage.getFilesPath();
    setState(() => _appFilesPath = appFilesPath);
    final docsFilesPath = await _fileStorage.getDocumentsPath();
    setState(() => _docsFilesPath = docsFilesPath);
    final cacheFilesPath = await _fileStorage.getCachePath();
    setState(() => _cacheFilesPath = cacheFilesPath);
    setState(() => _destination = appFilesPath);
  }

  Future<void> _load() async
  {
    final text = await _fileStorage.loadText(fileName);
    _textController.text = text ?? '';
    if (mounted && text == null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('The file does not exist'),
          content: Text('File path: $fileName'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _save() async
  {
    await _fileStorage.ensurePathExists(fileName);
    await _fileStorage.saveText(fileName, _textController.text);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text is successfully saved'),
        content: Text('File path: $fileName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  late TextEditingController _fileNameController;
  late TextEditingController _textController;

  String? _appFilesPath;
  String? _docsFilesPath;
  String? _cacheFilesPath;
  String? _destination;

  final _fileStorage = FileStorage();
}
