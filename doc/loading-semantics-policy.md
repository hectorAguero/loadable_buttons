# Loading semantics policy

This is the v2 accessibility contract for
[#36](https://github.com/hectorAguero/loadable_buttons/issues/36).

All Material and Cupertino constructors accept optional
`String? loadingSemanticsLabel` with the same null default and content ownership
policy. Future adaptive constructors must preserve that contract.

- Built-in transitions forward the label only to their default indicator.
  Applications supply a localized description of the operation; the package
  provides no fallback text. Rebuilding with a different label updates the
  current indicator, including during pending work.
- Effective loading combines external `loading` and a pending `onPressed` or
  `onError`. The label remains accessible until both loading sources clear.
- The outer native button stays disabled while loading. Progress content adds
  no button role or activation action. Inactive idle content and outgoing
  switcher content remain excluded from interaction, focus, and semantics,
  including when idle content is partially visible.
- A supplied `loadingChild` owns its accessible label and progress value.
  `loadingSemanticsLabel` is ignored, even if custom content has no label.
- A `customBuilder` owns all content semantics, including inactive and outgoing
  subtrees. It receives the original nullable `loadingChild`; there is no
  default indicator or added semantics wrapper. `loadingSemanticsLabel` is
  ignored. Extended FAB builders can run separately for icon and label slots.
- Intentional actions in current loading content, such as Cancel, remain
  accessible. The application owns cancellation and must finish the tracked
  Future and clear any external loading it owns.
- Loading labels do not opt in to live announcements. Applications may provide
  a separate live status region or announce operation state changes themselves.
  Do not announce from builders, ordinary rebuilds, or animation frames. Any
  future announcement API needs a separate transition-based contract.

The [README examples](../README.md#accessible-loading-content) show localization,
custom accessible progress, and intentional cancellation. Public widget
contracts in `test/src/async_button_contract_test.dart` own label visibility,
null defaults, locale updates, constructor forwarding, and custom-content
ownership. Existing transition tests own inactive-content isolation and active
loading-content actions; avoid duplicating that accessibility audit.
