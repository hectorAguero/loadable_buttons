# Loading transition audit (issue #12)

Audited on October 1, 2026 against `2afc62c` (main), using Flutter 3.47.5
stable and Dart 3.13.4. This base uses Flutter Material; consumer requirements
remain Flutter >=3.29.0 and Dart ^3.6.0. The minimum SDK versions were not run.

## Confirmed failures and fixes

Widget probes used nested interactive content, controlled Futures, and explicit
animation intervals before, during, and after both transition directions.
They did not use `pumpAndSettle` while an indicator was running.

| Baseline observation | Fix |
| --- | --- |
| Faded stack content in Filled, Outlined, Text, IconButton, and regular FAB accepted nested pointer input when loading content did not intercept it. Elevated already guarded pointers. | Guard inactive stack content in every family. |
| Stack content retained nested keyboard focus while loading, including Elevated. | Exclude focus from inactive content. |
| Outgoing switcher content retained interaction and focus until its animation ended. | Guard outgoing entries in the switcher's layout builder, using their current outgoing status in both directions. |
| Hidden nested controls could retain actionable accessibility content. | Exclude inactive content from the accessibility tree while preserving the outer Material button's disabled semantics. |
| Extended FAB mounted an invisible copy of its icon during loading, causing duplicate GlobalKey errors. | Keep a single icon subtree and remove the invisible duplicate. |
| Extended FAB always supplied an icon wrapper, even without an icon, and dropped extended padding, spacing, and text style. | Pass a null icon when absent and forward the native extended layout options. |
| Spinners in Filled, Outlined, Text, and IconButton fell back to the progress-indicator theme instead of the button theme; FAB used the color scheme's secondary color. | Resolve explicit foreground colors, then use inherited Material foreground colors. |

## Intended behavior retained

- Smaller loading content fits the idle stack size. Larger custom content can
  expand it within parent and Material constraints. This is documented behavior,
  not a size-preservation guarantee. Fixed-size FAB variants retain their native
  Material constraints.
- Switchers retain outgoing content for layout until it finishes fading. Both
  states can be mounted during a transition; only current content is interactive.
- A nonzero `minimumChildOpacity` keeps idle content faintly visible, without
  making it actionable during loading.
- Current custom loading content can have meaningful actions, such as canceling.
  Only inactive content is isolated. Custom builders keep their existing contract
  and own their interaction, focus, semantics, and sizing.
- Extended FAB stack transitions retain the icon area. The layout regressions
  compare against native Material with and without a keyed icon, constrained
  width, 2x text scaling, directional padding, and RTL/LTR ordering. Native
  extended FAB overflow/clipping behavior is retained for undersized parents.

## Accessibility API decision

No public API additions are needed for this fix. `loadingSemanticsLabel` remains
specific to Elevated's default indicator and defaults to null. No English label
or automatic localized announcement is introduced. All families accept custom
loading content with localized semantics. Consumers own labels and announcements
for `loadingChild`; `customBuilder` also owns inactive/outgoing content semantics.
These changes belong in a patch release without changing constructor defaults or
consumer SDK constraints. The README documents these responsibilities.

## Regression scope

`test/src/async_button_transition_test.dart` protects pointer, keyboard, focus,
and accessibility behavior through the public widgets, including loading-to-idle
transitions and rapid reversal. It also checks Material foreground themes,
custom-content sizing, and extended-FAB keyed icons and layout. The existing
long-press checks retain their disabled-state contract; loading no longer exposes
the hidden idle label. Existing switcher tests synchronize with the configured
transition duration rather than requiring outgoing widgets to disappear early.

Validation on Flutter 3.47.5 / Dart 3.13.4:

- The complete suite passes all 224 tests, including 50 focused transition checks.
- `bash tool/analyze.sh` and the CI Dart Code Linter command pass.
- Changed-file formatting and `git diff --check` pass.
- The macOS example builds and hot reloads without runtime errors.
