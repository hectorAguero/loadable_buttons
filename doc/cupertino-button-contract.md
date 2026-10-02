# Cupertino button contract

`AsyncCupertinoButton` wraps the standalone `cupertino_ui` native default,
filled, and tinted constructors. `package:loadable_buttons/cupertino.dart`
exports those buttons, `AsyncButtonErrorHandler`, and `TransitionAnimationType`
without importing Material implementation code. The combined barrel and
`material.dart` retain all Material APIs.

The direct dependency is `cupertino_ui >=1.0.0 <2.0.0`. Version 1.0.0 supplies
all supported native options and declares Flutter >=3.44 / Dart ^3.12, matching
the existing package minimum. The deprecated `minSize` argument is omitted in
favor of `minimumSize`. Latest resolution remains SDK-dependent.

Shared loading state and transitions use Flutter widgets. Material layers and
indicators live in `async_material_button_helpers.dart`; Cupertino presentation
and its indicator remain together in `async_cupertino_button.dart` for copying.

| Public/native contract | Primary test owner | Regression detected |
| --- | --- | --- |
| All three native variants and small/medium/large sizes; default and explicit padding, minimum size, alignment, background/foreground colors, radius, typography, press fading, and disabled appearance | `async_cupertino_button_test.dart` native reference matrix | Forwarding to the wrong variant, ignoring a native option, or changing rendered layout/feedback under CupertinoApp. Native reference widgets supply independent expectations, including light/LTR defaults and dark/RTL overrides. |
| Focus color, focus node, focus changes, autofocus, and mouse cursor | `async_cupertino_button_test.dart` | Dropping a native focus or cursor option at the forwarding boundary. |
| Internal OR external loading and locking before the first rebuild | `async_button_loading_test.dart` shared constructor matrix | Duplicate activation or premature unlocking when either loading source changes. |
| Public GlobalKey ownership, retained state, stale callbacks, and long-press-only activation | `async_cupertino_button_test.dart` | Duplicate key ownership, lost pending work, or long presses escaping the synchronous lock. |
| Original errors/stacks, handler forwarding, and retry | `async_button_contract_test.dart` and `async_button_error_test.dart` shared matrices | Consuming unhandled failures or skipping an explicitly supplied error handler. Recovery/capture/disposal policy stays owned by the existing shared-helper tests. |
| Stack, switcher, and custom-builder content; nullable custom loading content | `async_button_contract_test.dart` shared matrix | Missing current content, applying a builder outside custom mode, or substituting an unwanted default indicator. |
| Localized default loading label, null default, locale updates, disabled outer role, and keyboard/semantics activation | `async_button_contract_test.dart` shared matrix | Hidden labels remaining accessible or loading buttons advertising activation. |
| Inactive content cannot receive pointer input, focus, or semantics actions; current loading content remains actionable | `async_cupertino_button_test.dart` | Cupertino wiring bypassing guards or disabling a custom Cancel action. |
| Default Cupertino spinner uses the theme primary color or explicit foreground on every variant, and stays within the idle text size across native sizes and text scaling | `async_cupertino_button_test.dart` | Material indicator dependency, a contrasting spinner disappearing on the disabled fill shown while loading, or stack loading resizing the button. |

All tests observe public widget behavior or the native renderer, with no
production API or keys added solely for testing. Existing contract matrices are
extended instead of replaying shared state-machine tests in a second suite.
Native reference measurements protect the documented native layout contract;
they do not fix expectations to numeric sizes or one Cupertino release.

Native CupertinoButton currently omits enabled-state semantics and advertises a
tap action even when disabled. A small render adapter supplies enabled state and
blocks actions only on the assembled outer semantics node. Blocking the entire
subtree would disable intentional loading actions. Custom loading content gets
its own semantics boundary; its labels, roles, and actions remain consumer-owned.
Custom builders retain responsibility for all content semantics and boundaries.

Run `bash tool/resolve_design_ui.sh oldest|latest` to pin or unlock both design
libraries for the package and example. CI runs the full suite and analyzer/plugin
checks in four combinations: exact Flutter 3.44.0 and stable, each with both
libraries at 1.0.0 or their latest compatible releases. The old Material resolver
name remains a forwarding entry point for existing development commands.
