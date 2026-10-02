import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The skills CLI requires names prefixed with the package name.
const _skillPrefix = 'loadable-buttons-';

String _frontmatterValue(String frontmatter, String key) {
  final match = RegExp(
    '^$key:[ \\t]*(.+)\$',
    multiLine: true,
  ).firstMatch(frontmatter);

  return match?.group(1)?.trim() ?? '';
}

void main() {
  final skillDirectories = Directory(
    'skills',
  ).listSync().whereType<Directory>().toList();

  test('package ships at least one consumer skill', () {
    expect(skillDirectories, isNotEmpty);
  });

  for (final directory in skillDirectories) {
    final name = directory.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );

    group('skill $name', () {
      final skillFile = File('${directory.path}/SKILL.md');

      test('has frontmatter matching the skills CLI contract', () {
        expect(name, startsWith(_skillPrefix));
        expect(skillFile.existsSync(), isTrue);

        final content = skillFile.readAsStringSync();
        final frontmatter = RegExp(
          r'^---\n([\s\S]*?)\n---\n',
        ).firstMatch(content)?.group(1);
        if (frontmatter == null) fail('SKILL.md has no frontmatter.');

        expect(_frontmatterValue(frontmatter, 'name'), name);
        expect(_frontmatterValue(frontmatter, 'description'), isNotEmpty);
      });

      test('resolves every relative Markdown link', () {
        final markdownFiles = directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'));
        final link = RegExp(r'\]\(([^)#\s]+)(?:#[^)]*)?\)');

        for (final file in markdownFiles) {
          for (final match in link.allMatches(file.readAsStringSync())) {
            final target = match.group(1) ?? '';
            if (target.contains('://')) continue;
            expect(
              File.fromUri(file.uri.resolve(target)).existsSync(),
              isTrue,
              reason: '${file.path} links to missing $target',
            );
          }
        }
      });
    });
  }
}
