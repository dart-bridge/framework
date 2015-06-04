import 'dart:io';

main() async {
  var testDir = new Directory('test');
  var listOfFiles = <String>[];

  await for (FileSystemEntity entity in testDir.list(recursive: true, followLinks: false)) {
    FileStat stat = await entity.stat();

    if (!(stat.type == FileSystemEntityType.FILE && entity.path.endsWith('_test.dart')))
      continue;

    listOfFiles.add(entity.absolute.path.replaceFirst(testDir.absolute.path, ''));
  }

  var script = "export 'package:testcase/testcase.dart';\n" +
    listOfFiles.map((f) => "export '$f';\n").join('\n');

  await new File('${testDir.path}/all.dart').writeAsString(script);
}