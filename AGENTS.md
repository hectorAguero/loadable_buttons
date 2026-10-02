# Repository guidance

Read [CONTRIBUTING.md](CONTRIBUTING.md) for development and validation commands.

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
