# Button source structure: history and cleanup

Initial source-history review completed October 2, 2026 against `56a9c36` (PR #53), with
`a2e80d7` as its main-branch base. Rechecked against merged main `8016125`
(PR #53) on the same day: the production structure was unchanged. The cleanup
below is implemented in the follow-up PR for
[issue #54](https://github.com/hectorAguero/loadable_buttons/issues/54).

The original two-file structure separated icon construction and layout from
the family's public API, State, loading, and native button construction.
Icon variants already inherited the same loading State as regular buttons.
In v1.1.1, icon-padding wrappers gained shared loading-layer responsibilities
and started serving regular buttons too. Their names and file placement were
not adjusted to reflect that broader role.

## Evidence and release identification

For this review, "v1" means the published 1.0.0 release, with 1.0.1 and 1.1.0
checked as intermediate releases. The repository has tags for v1.1.0 and
v1.1.1, but no local v1.0.0 tag. A pubspec version alone is insufficient:
several later development commits still declared 1.0.0.

Downloaded the official source archives identified by
[pub.dev release metadata](https://pub.dev/api/packages/loadable_buttons),
verified each archive's SHA-256 against that metadata, and compared the main
and icon companion files for Elevated, Filled, Outlined, and Text. All eight
source files match the following Git snapshots byte for byte:

| Published version | Verified source snapshot | Observed construction |
| --- | --- | --- |
| 1.0.0 | [c862ce7](https://github.com/hectorAguero/loadable_buttons/commit/c862ce794ee975c4a1c4581e0b128f66910d25f5) | Shared family State ultimately constructs regular native Material buttons; Filled selects `FilledButton` or `FilledButton.tonal` explicitly. Icon parts contain constructor adapters and icon/label layout. |
| 1.0.1 | [2afc62c](https://github.com/hectorAguero/loadable_buttons/commit/2afc62cd56abd029bb4ec41e11220f79e24ac417) | Same separation and native construction shape, with callback/key/loading fixes. |
| 1.1.0 | [v1.1.0 / 18087e8](https://github.com/hectorAguero/loadable_buttons/tree/18087e8aeaf3eade60f6aa6ec03ddda3e330ff71/lib/src) | Same icon companion role; shared loading and indicator helpers have been consolidated. Filled still uses explicit regular/tonal construction. |
| 1.1.1 | [v1.1.1 / 3e51253](https://github.com/hectorAguero/loadable_buttons/tree/3e51253834753861e6e16e1773c8df9277371ae0/lib/src) | Main builds route through wrappers named `*WithIconPadding` for both regular and icon variants. Filled selects wrapper constructors through `buttonBuilder`. |

The [v1.1.1 release notes](https://github.com/hectorAguero/loadable_buttons/releases/tag/v1.1.1)
identify native icon padding and centering stack loaders within the whole button
as intended fixes. The following file-responsibility interpretation comes from
the inspected code; it is not a quotation of an original architecture decision.

## What the original split actually separated

For each of the four families, `async_*_button.dart` declares a `part` for
`async_*_button_with_icon.dart`. These are two source files in one Dart library,
with shared private declarations, rather than independently importable widgets.

The main file owns:

- The public async widget and its constructors, including `.icon` and, for
  Filled, `.tonal` and `.tonalIcon`.
- The icon factory's null-icon fallback to the regular constructor.
- The family's `createState`, async callback tracking, and effective loading.
- Native Material button construction and loading presentation.

The icon companion originally owns:

- `_Async*ButtonWithIcon`, a private subclass of the public async widget.
  It converts `icon` plus `label` into the base widget's `child`, forwards
  constructor arguments, and preserves the Filled tonal variant.
- `_*ButtonWithIconChild`, the icon/label row with spacing, text scaling, and
  icon alignment.

None of the four published companion files has its own `State` or overrides
`createState`, in any of the four inspected releases. Their private async
subclasses inherit the main widget's State. For example, in
[1.0.0's Filled icon part](https://github.com/hectorAguero/loadable_buttons/blob/c862ce794ee975c4a1c4581e0b128f66910d25f5/lib/src/async_filled_button_with_icon.dart),
the subclass passes an icon/label row to `super`; the
[main file](https://github.com/hectorAguero/loadable_buttons/blob/c862ce794ee975c4a1c4581e0b128f66910d25f5/lib/src/async_filled_button.dart)
creates `_AsyncFilledButtonState`, which chooses the regular or tonal native
button and applies the loading presentation.

The original split therefore separated icon-specific construction and
presentation. The files never represented separate implementations of async
loading and activation. Keeping that logic shared is compatible with restoring
a clearer file boundary.

## How v1.1.1 changed the boundary

Two commits in the development history of PR #50 explain the transition.

1. [b3edd79: Fix native icon button padding](https://github.com/hectorAguero/loadable_buttons/commit/b3edd7980dc14bfe516f0327f62a844dde5bdb73)
   introduces `_*ButtonWithIconPadding` in the icon companion files. These
   subclasses override `defaultStyleOf` using the native icon constructor's
   defaults, while keeping the entire async content as the button child.
   At this intermediate stage, only icon widgets use the wrapper; regular
   widgets still use the ordinary native constructor. Constructor tear-off
   variables select between those paths; Filled has regular and tonal builders.
2. [9a6e409: Center stack loading content within full button bounds](https://github.com/hectorAguero/loadable_buttons/commit/9a6e409134c5af20533fba6c94544288d9f4424b)
   adds `StackLoadingButton` to those wrappers and a `hasIcon` flag. Every
   regular/icon widget now uses the wrapper, because full-button loading-layer
   handling is needed for both. Elevated, Outlined, and Text stop selecting
   constructor tear-offs. Filled retains one `buttonBuilder`, now selecting
   only the regular versus tonal wrapper constructor.

The final v1.1.1 release also restricts Filled custom-builder invocation to
custom transition mode. Copying the earlier build method wholesale would
lose fixes beyond this structural concern.

The v2 Material UI migration in
[fc39156 / PR #51](https://github.com/hectorAguero/loadable_buttons/commit/fc391567b2af2f98d373bfc81d9a7c9a38c4432c)
retains this structure. PR #53 adds loading-label forwarding to the existing
paths. Neither PR introduced the regular button's dependency on an icon-named
wrapper; that is already present in the published v1.1.1 sources.

## What the shared wrappers did before cleanup

In [Filled's wrapper at the reviewed revision](https://github.com/hectorAguero/loadable_buttons/blob/56a9c36ba97642652784738afde15d706cfc67cc/lib/src/async_filled_button_with_icon.dart#L73),
`hasIcon: false` returns `super.defaultStyleOf(context)`. It keeps regular
Filled defaults, or tonal defaults when constructed through `super.tonal`.
Only `hasIcon: true` obtains defaults from `FilledButton.icon` or
`FilledButton.tonalIcon`. Equivalent guards exist for Elevated, Outlined, and Text.
Constructing the icon-named wrapper does not turn a regular button into an icon
variant.

The second responsibility comes from
[StackLoadingButton](https://github.com/hectorAguero/loadable_buttons/blob/56a9c36ba97642652784738afde15d706cfc67cc/lib/src/async_button_helpers.dart#L68):
for stack transitions it retains idle content as the native button child and
presents the guarded loading transition in the native background layer. This
centers loading content within the entire button, including asymmetric padding,
while preserving Material styling, constraints, and interaction bounds. It also
composes any supplied or inherited background builder. Other transition modes
retain their ordinary child/style path.

The wrapper therefore has a legitimate shared purpose. Its icon-only name and
location hide that purpose. Replacing regular-path wrappers with bare Material
constructors would need another way to preserve the full-button loading layer.

`buttonBuilder` is a constructor tear-off, not the consumer's `customBuilder`.
It selects Filled versus tonal native superclass wiring and avoids repeating
arguments. That saves lines but makes the constructor choice indirect.

## Cleanup scope

The cleanup keeps the two files per family and restores their responsibility
split, with the history above as its rationale.

| Previous shared wrapper | Updated name | Location |
| --- | --- | --- |
| `_ElevatedButtonWithIconPadding` | `_LoadingElevatedButton` | `async_elevated_button.dart` |
| `_FilledButtonWithIconPadding` | `_LoadingFilledButton` | `async_filled_button.dart` |
| `_OutlinedButtonWithIconPadding` | `_LoadingOutlinedButton` | `async_outlined_button.dart` |
| `_TextButtonWithIconPadding` | `_LoadingTextButton` | `async_text_button.dart` |

- Move and rename the shared native wrappers into their main files, beside
  the State that constructs them. Explain their full-button loading role.
- Keep the private async icon subclasses and icon/label row widgets in the
  existing icon companions. These remain meaningful icon-specific boundaries.
- Replace Filled's `buttonBuilder` dispatch with explicit regular/tonal
  construction, using a readable `if` or `switch`. Preserve actual superclass
  constructor forwarding through `.new` and `.tonal`; do not merely change a
  color or style flag to imitate tonal behavior.
- Accept deliberate repetition of native named-argument wiring where it makes
  the choice clearer. Keep any shared loading-content expression cohesive;
  avoid replacing one indirect builder with a broad generic factory abstraction.
- Keep async activation/error ownership in the existing shared helper and
  family State. Separate files do not require separate loading state machines.
- Add no files just for individual declarations. Preserve the repository's
  copyability guidance and update README copy instructions if dependencies or
  `part` relationships actually change. Moving a private class within the same
  library does not make the companion optional for consumers copying source.

This is an internal refactor with no public API change. A more extensive
separation of native icon/default-style behavior can be evaluated later if it
improves clarity without multiplying files or loading implementations.

## Acceptance criteria and validation

- Regular builds no longer construct a class whose name implies icon-only
  behavior. Shared native wrappers live with their common owner; companion
  files contain the actual icon-specific construction and layout.
- Filled's regular/tonal selection is explicit, without the constructor
  tear-off `buttonBuilder` variable. Native constructor options remain intact.
- Public constructors, null-icon fallback, keys, callbacks, external/internal
  loading ownership, and `onError` behavior remain compatible.
- Preserve native icon padding and state-dependent widget/theme/default style
  precedence, full-button stack centering, clipping, background builders,
  custom loading actions, and inactive/outgoing-content isolation.
- Preserve `loadingSemanticsLabel` forwarding and custom-content ownership
  from PR #53; this follow-up starts from that merged baseline.
- Validate behavior with the existing public contract and native-reference
  tests. Do not add tests that assert private wrapper names, source-file
  placement, or exact wrapper ancestry. This is a readability change, so new
  coverage needs an independently uncovered behavior risk.
- Run the commands in [CONTRIBUTING.md](../CONTRIBUTING.md#local-checks), including
  formatting, package/test/example analysis, plugin checks, DCL checks, tests,
  and whitespace validation. Check the exact minimum and stable SDKs with
  exact-oldest and latest-compatible Material UI resolution. The current v2
  floor is Flutter 3.44 / Dart 3.12 with Material UI >=1.0.0 <2.0.0.

Useful existing regression owners are `async_button_icon_padding_test.dart`,
`async_button_icon_interaction_test.dart`, `async_button_transition_test.dart`,
and `async_button_contract_test.dart`, alongside the existing key, loading,
long-press, disabled, and error contracts. Preserve those independently tested
requirements when simplifying the implementation.

## Review and implementation record

Checked all four published releases against eight relevant family source files,
verified archive checksums, traced the two structural changes in PR #50, and
compared the v2 migration and PR #53 paths. Re-downloaded the official archives
and repeated their SHA-256 and eight-file Git comparisons for this follow-up;
all four release snapshots still match. Historical runtime behavior was not
re-executed for this source-history review.

Moved and renamed the four native wrappers into their main files. Filled now
builds its loading content and shared forwarded values once, then uses an
exhaustive `switch` on its variant to choose `_LoadingFilledButton` or
`_LoadingFilledButton.tonal`, matching native `FilledButton` variant dispatch
and retaining native superclass construction and all forwarded options. Icon adapters and layout widgets stay in their companion
parts; imports, public declarations, shared helpers, and tests are preserved.
README copy instructions still require the companion parts and shared helpers
and remain accurate.

The existing native-reference and behavior tests remain the regression owners:
native padding is compared against independent Material constructors, and
interaction tests protect full-button centering and usable loading controls.
No tests for private names, source placement, or wrapper ancestry were added.

Completed the following local validation on October 2, 2026. Every combination
passed formatting, package/test/example analysis with plugins, the isolated DCL
CLI, and all 733 tests. Material UI versions were verified in both package roots.

| Flutter / Dart | Material UI resolution | Result |
| --- | --- | --- |
| 3.44.0 / 3.12.0 | Exact oldest 1.0.0 | Passed |
| 3.44.0 / 3.12.0 | Latest compatible 1.2.0 | Passed |
| 3.47.5 / 3.13.4 (stable) | Exact oldest 1.0.0 | Passed |
| 3.47.5 / 3.13.4 (stable) | Latest compatible 1.5.0 | Passed |

The minimum/latest run initially reused generated test assets from the oldest
resolution and failed to find Material's `ink_sparkle.frag` shader. Removing
that isolated checkout's generated build directory and rerunning with the same
resolved dependencies passed all tests without source or test changes.
`git diff --check` also passed. The primary checkout finishes on stable with
latest-compatible Material UI resolution; isolated copies covered the other
combinations.
