# Repository guidance

Read [CONTRIBUTING.md](CONTRIBUTING.md) for development and validation commands.

## Editing and tooling

- Prefer direct/patch edits for small, localized changes. Choose mechanisms for
  safety and efficiency; do not force a CLI tool merely because it is installed.
- For terminal search, prefer `rg` for text and `fd` for file discovery;
  `rg --files` is also useful for repository file lists.
- Reuse repository scripts and codemods before inventing transformations.
  Use `sd` or scripts for safe, repetitive mechanical changes when more efficient.
  Avoid ad-hoc Python for simple edits; keep it available for complex bulk work.
- When Dart changes depend on syntax, symbols, imports, types, or semantics,
  use Dart-aware tooling or targeted patches instead of naive text replacement.
- Prefer direct YAML/pubspec edits for small changes. Use `yq` when structured
  updates are safer, without rewriting unrelated content, comments, formatting,
  quoting, or ordering.
- Use established generation workflows for generated files; do not edit them
  manually. Inspect the resulting diff and run `git diff --check`.

Format changed Dart files with `dart format <files>`; only format the whole
repository when intentionally requested. After relevant Dart/Flutter changes,
run `flutter analyze`, appropriate tests, and the required CONTRIBUTING checks,
including `bash tool/analyze.sh` for plugin diagnostics. After dependency changes,
use the repository's normal resolution workflow (Material UI uses
`bash tool/resolve_material_ui.sh` with the appropriate mode); otherwise run
`flutter pub get` in the affected package roots.

## File organization and copyability

This package supports copying button implementations into application projects.
Prefer fewer cohesive source files to reduce the files and imports consumers
need to copy and adapt.

- Keep small related typedefs, callbacks, and utilities with their existing
  implementation or shared helpers. For example, `AsyncButtonErrorHandler`
  belongs in `lib/src/async_button_helpers.dart` alongside its error policy.
- A public declaration does not require its own file. Export the intended
  symbols from `lib/loadable_buttons.dart` with `show` when their source file
  also contains internal helpers.
- Introduce a separate file when it establishes a meaningful feature boundary
  or materially improves readability and maintenance. Avoid splitting files
  merely to put each declaration in its own file.
- Keep the README's copy instructions accurate when changing source files,
  imports, or companion `part` files.

## Readability and native behavior

- Prefer `if`, ternaries, and `is` for simple choices. Use switches or patterns
  when they clarify branching or add useful exhaustiveness.
- Keep locals and private widgets that clarify responsibilities or preserve
  behavior. Reducing their count alone is not a reason to refactor.
- Keep shared native loading wrappers in family main files and icon adapters
  and layout in companion parts. Preserve explicit Filled regular/tonal
  construction and native superclass wiring.

## Structural audits

Use the optional commands in [CONTRIBUTING.md](CONTRIBUTING.md#optional-structural-audits)
when a maintainability review would benefit from them. Treat findings as review
leads: preserve intentional Material constructor wiring, exported package APIs,
and cohesive helpers. Evaluate external skill rules against this repository's
copyability and SDK requirements before adopting them.
