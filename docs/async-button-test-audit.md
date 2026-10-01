# Async button contract test audit (issue #13)

Cleanup of the six original family test files, reviewed on October 1, 2026
against `499f28f` with Flutter 3.47.5 / Dart 3.13.4. The baseline suite passes.
This checkout uses Flutter Material and retains its existing consumer SDK floor.
The decisions below were recorded before deleting tests.

## Existing regression owners: KEEP

| Issue | Primary proof retained | Independent failure detected |
| --- | --- | --- |
| #6 | `test/src/async_button_loading_test.dart` | External updates unlock pending work, same-frame activation repeats it, or completion overrides external loading. |
| #7 | `test/src/async_button_disabled_test.dart` | Null callbacks advertise enabled semantics or allow activation; restoring callbacks fails. |
| #8 | `test/src/async_button_long_press_test.dart` | Loading accepts long presses or keyboard activation, including a callback captured before a rebuild; long-press-only idle behavior breaks. |
| #9 | `test/src/async_button_key_test.dart` | A public GlobalKey mounts twice or rebuilding loses pending work and state. |
| #10 | `test/src/async_button_icon_interaction_test.dart` | Adding an icon drops long press, hover, explicit focus, or focus-change callbacks. |
| #11 | Selection groups in `test/src/async_icon_button_test.dart` | Selection fails to change icons, resolved color, or semantics; loading bypasses selected content. The old incorrect `isSelected property is handled` expectation was already replaced by the #11 fix. |
| #12 | `test/src/async_button_transition_test.dart` | Hidden/outgoing content accepts pointer, focus, or semantic actions; loader themes, keyed extended-FAB content, or native layout regress. |

These tests exercise public requirements at widget boundaries and detect
independent failures. No regression from these fixes is duplicated in a new
cleanup-specific file. Existing native-layout comparisons have an independent
Material reference, and GlobalKey ownership is itself a public API contract.

## Elevated, Filled, Outlined, and Text files

Each row names the complete tests in
`test/src/async_elevated_button_test.dart`,
`test/src/async_filled_button_test.dart`,
`test/src/async_outlined_button_test.dart`, and
`test/src/async_text_button_test.dart`, except the Filled-only rows.
Their production owners are the corresponding public button and its icon
factory in `lib/src/async_*_button.dart` and companion parts.

| Disposition | Exact original test | Actual proof and reason |
| --- | --- | --- |
| DELETE | `renders child correctly` | Only initial fixture text. The controlled default-indicator contract verifies idle content before and after work. No behavioral replacement is warranted. |
| REWRITE | `shows loading indicator when pressed` | Detects a missing default spinner, but completion depends on an arbitrary one-second callback. Move to the shared constructor matrix with a Completer and retry after completion. |
| REWRITE | `handles different transition types` | Only initial text; never exercises its configured switcher. The shared transition round trip checks current content in both directions and waits for outgoing fades. |
| DELETE | `icon variant renders correctly` | Only icon/label fixtures. The #10 icon interaction/loader-centering tests already use both rendered content regions, and the shared constructor contracts exercise the variant. No behavioral replacement is warranted. |
| REWRITE | `custom builder works correctly` | Only initial text; would pass if loading were always false. The shared custom-builder contract renders distinct states and uses the supplied loadingChild, including the nullable case. |
| DELETE | `button is disabled during loading` | One externally blocked tap. #6 already protects blocking through pending work and external changes, and #8 protects loading semantics/keyboard. No behavioral replacement is warranted. |
| DELETE | `handles long press correctly` | One idle callback. #8 tests restoration and idle long-press-only behavior; #10 covers icon parity. No behavioral replacement is warranted. |
| DELETE | Filled: `tonal variant renders correctly` | Text plus internal FilledButton existence cannot distinguish tonal behavior. Key, long-press, theme, and shared constructor contracts retain behavioral coverage. No behavioral replacement is warranted. |
| DELETE | Filled: `tonal icon variant renders correctly` | Same fixture/tree proof as the icon smoke test. #9/#10 and the shared constructor contracts protect its independent behavior. No behavioral replacement is warranted. |

Every test in these four files is classified, so the files can be removed after
their meaningful contracts move to the matrix. Removal risk is losing initial
fixture detection only; no production helper or API is removed.

## IconButton and FAB files

Owners are `AsyncIconButton` and `AsyncFloatingActionButton`, their constructor
branches, and the shared transition widget. Paths are
`test/src/async_icon_button_test.dart` and
`test/src/async_floating_action_button_test.dart`.

| Disposition | Family and exact original test | Evidence / independent owner |
| --- | --- | --- |
| DELETE | Icon: `renders icon correctly`; FAB: `renders child icon correctly (regular)` | Initial fixtures only; selection fallback and shared idle/loading contracts are stronger. No behavioral replacement is warranted. |
| REWRITE | Icon: `shows loading indicator when pressed` | Keep its distinct selected/default-spinner combination as `default indicator covers selected content and restores it`, using a Completer and selected semantics. The shared default-indicator matrix is unselected; #11's selection matrix supplies a custom loader. |
| REWRITE | Icon: `handles stack transition type`, `custom builder works correctly`, `filled variant shows loading indicator`, `filledTonal variant shows loading indicator`, `outlined variant shows loading indicator`; FAB: `shows loading indicator when pressed (regular)`, `custom builder works correctly`, `small variant shows loading indicator`, `large variant shows loading indicator`, `extended variant with custom loadingChild in label` | Meaningful default/custom loading content, repeated with guessed callback delays. Consolidate into Completer-controlled constructor/transition contracts. Selection-specific loading remains owned by #11. |
| DELETE | Both: `prevents multiple taps while async is running` | Delayed repeat tap is weaker than the #6 same-frame and external-update regression. No behavioral replacement is warranted. |
| DELETE | Icon: `button is disabled during loading`; FAB: `button is disabled during external loading` | Single blocked tap duplicates #6. No behavioral replacement is warranted. |
| KEEP | Both: `switcher completes both fades around a pending operation` | Default indicators animate indefinitely; distinct family-specific proof that outgoing spinner/icon content is removed after each configured fade. Uses a Completer and bounded animation waits. |
| KEEP | Icon: `handles long press correctly`, `onLongPress does not fire while loading (onPressed disabled)` | IconButton's native long-press behavior differs from ButtonStyleButton. Real gestures protect an independent callback contract. |
| KEEP | Icon: `onHover callback fires on mouse enter/exit` | Real pointer movement reports both public callback values; no stronger standard-IconButton owner overlaps it. |
| KEEP | FAB: `asserts when customBuilder is not provided with custom transition`; Icon: `asserts when customBuilder is not provided with customBuilder transition`, `asserts when using splashFactory together with style`, `asserts when splashRadius <= 0 on filledTonal`, `asserts when splashRadius <= 0 on outlined` | Public constructor validation rejects invalid input. These do more than prove a constructor exists. |
| REWRITE | Icon: `tooltip is displayed` | byTooltip finds configured metadata without displaying anything. Long press must reveal the tooltip text. |
| REWRITE | Icon: `forwards constraints and mouseCursor to IconButton` | Property echoes do not prove layout or pointer behavior. Observe the rendered constrained area and the cursor selected for a mouse over it. |
| KEEP | Icon: `default loading indicator takes color from style.foregroundColor`; FAB: `default loading indicator color uses foregroundColor` | Explicit foreground API affects the rendered indicator, independently of inherited-theme regressions. Replace callback timers with Completers. |
| REWRITE | Both: `minimumChildOpacity is applied in stack transition` | Inspects exact AnimatedOpacity/AnimatedSize/Visibility structure, so a private refactor breaks it. Check the painted idle content with a controlled loadingChild instead. |
| DELETE | FAB: `extended variant shows loading in label, keeps icon area` | Finds mounted icons with a permissive count; #12's keyed-icon, native-layout, and loader-centering tests give stronger proof, alongside the shared extended constructor contract. No behavioral replacement is warranted. |
| KEEP | Icon selection groups: `toggles icons, resolved color, and selection semantics`, `keeps the original icon without a selected icon or state`, `resolves selection for disabled and loading states`, and `${transition.name} keeps loading above selected content` for each variant | #11 regressions already prove independent selection/fallback/state-resolution/loading behavior through content and accessibility. Preserve unchanged. |

## New/rewritten contract gate

The shared fixture uses public constructor tear-offs and thin adapters for
child/icon/label names. It exposes no production seam and computes no expected
results. Repeated scenarios have one owner, including all constructor branches.

| Contract | Credible failure | Why existing coverage needs it |
| --- | --- | --- |
| Default indicator round trip and semantic retry | A constructor omits the spinner, leaves the operation locked, or fails to deliver accessibility activation after completion. | Existing per-family timers are replaced; no prior matrix invokes the outer button's semantic tap action. |
| Custom content and all three transitions | LoadingChild/customBuilder is dropped or receives a stale loading value. | Original text-button tests never enter loading; #12 covers built-in interaction guards rather than custom builders. |
| Nullable custom loadingChild | Builder never receives null or fails to render its fallback on loading. | No existing test uses the nullable argument in both directions. |
| Synchronous throw and failed Future | Errors are swallowed or internal loading remains locked, blocking retry. | Successful completion in #6 does not exercise exception cleanup or error propagation. |
| Disposal during a pending callback | Completion updates a disposed State or the operation is cancelled. | #9 rebuilds a mounted widget; it does not dispose pending work. |
| IconButton/FAB keyboard and semantic tap availability | Idle/restored keyboard activation fails, loading advertises a tap action, or pending/external loading accepts activation. | #7 uses null callbacks, #8 covers text-button long presses, and #12 covers nested content. Semantic retry itself is owned by the default-indicator matrix for all constructors. |

Expectations are caller effects, visible/accessible content, painted output, or
public constructor validation. They remain independent of private State names,
transition wrappers, and widget-tree counts. No public API exists only for tests.

Focused validation: `flutter test --no-pub test/src/async_button_contract_test.dart
test/src/async_button_opacity_test.dart test/src/async_button_loading_test.dart test/src/async_icon_button_test.dart
test/src/async_floating_action_button_test.dart`. Then run the complete suite,
`bash tool/analyze.sh`, the CI DCL command, changed-file formatting, and
`git diff --check`. Minimum-SDK execution is outside this change's validation.

## Completed cleanup and validation

The six original family files were audited and cleaned up. Static fixture tests,
internal-property echoes, exact transition-tree assumptions, and weaker duplicate
interactions were removed or rewritten according to the tables above. The four
text-button family files were removed after every test was classified; their
valid contracts now have a shared owner. IconButton/FAB-specific checks and
the existing #6–#12 regressions remain. The #6 matrix now shares the constructor
fixture and covers all 18 constructors without copying its scenarios.

Production LOC change: **0**. Test/test-support LOC: **3,113 → 2,259 (-854)**.
No production seams, exports, keys, or APIs were added or removed. The new keys
are confined to the painted-content test fixture. No coverage or count gate was
used to justify additions or deletions, and no unrelated failing test was removed.

Validation on Flutter 3.47.5 stable / Dart 3.13.4:

- The affected contract, opacity, ownership, IconButton, and FAB files pass.
- `flutter test --no-pub` passes the complete suite (369 cases).
- `bash tool/analyze.sh` passes both package-wide and explicit-file analysis.
- `dart run dart_code_linter:metrics analyze lib test example/lib --fatal-style --fatal-performance` passes.
- Changed-file formatting and `git diff --check` pass.
- Isolated temporary copies confirm that omitting exception cleanup, omitting
  the mounted guard, ignoring customBuilder, or ignoring minimumChildOpacity
  each causes its intended observable assertion to fail. Production files in
  this checkout were not mutated. The opacity proof samples painted output,
  so changing private transition wrapper types does not affect its assertions.

No unresolved test failures, policy conflicts, or production changes remain.
The minimum supported SDK was not executed; this PR preserves its constraints
and does not require a release note for a behavior change. No follow-up cleanup
is required for the audited scope.
