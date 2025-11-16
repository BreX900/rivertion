import 'dart:io';

import 'package:path/path.dart';
import 'package:recase/recase.dart';

void main() {
  final templates = Directory('tool/templates').listSync().whereType<File>();

  File('bin/src/templates.dart').writeAsStringSync('''
abstract final class Templates {
${templates.map((template) {
    final content = template.readAsStringSync();
    return """
  static const (String, String) ${basenameWithoutExtension(template.path).camelCase} = (
    '${basename(template.path)}',
    ${content.contains('\$') ? 'r' : ''}'''
$content''',
  );
""";
  }).join('\n')}
}
    ''');
}
