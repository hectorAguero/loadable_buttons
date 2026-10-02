# Customizing loading content

Read this when replacing the default spinner, choosing a transition, writing a
`customBuilder`, using IconButton selection, or controlling button size. The
core loading, error, and disabled rules in [SKILL.md](../SKILL.md) still apply.

## Transitions

| `TransitionAnimationType` | Behavior |
| --- | --- |
| `stack` (default) | Keeps idle content in the layout and fades loading content over it. |
| `animatedSwitcher` | Fades between idle and loading content; outgoing content stays in layout until its fade ends. |
| `customBuilder` | Calls the required `customBuilder(loading, child, loadingChild)`. |

- `animationDuration` defaults to 200 milliseconds (`Durations.medium1` on
  Material buttons).
- `minimumChildOpacity` sets the idle content's opacity while a `stack`
  transition is loading. The default `0.0` hides idle content completely;
  a value above zero, such as `0.3`, keeps it partially visible behind the
  loading content. Either way, idle content cannot receive pointer input,
  focus, or accessibility actions while loading. Other transitions ignore it.
- Selecting `customBuilder` without a `customBuilder` fails an assertion.
  A `customBuilder` is ignored by the other transition types.

## Custom loading content

`loadingChild` replaces the default spinner in built-in transitions:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  loadingChild: Text(l10n.saving),
  transitionType: TransitionAnimationType.animatedSwitcher,
  animationDuration: const Duration(milliseconds: 250),
  child: Text(l10n.save),
);
```

Custom content owns its semantics. `loadingSemanticsLabel` is ignored, even if
the custom content has no label. Label progress indicators directly:

```dart
AsyncFilledButton(
  onPressed: saveChanges,
  loadingChild: SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(
      value: progress, // Application-owned value between 0.0 and 1.0.
      semanticsLabel: l10n.savingChanges,
      semanticsValue: l10n.percentComplete((progress * 100).round()),
    ),
  ),
  child: Text(l10n.save),
);
```

On Cupertino, use `CupertinoActivityIndicator` or other Cupertino content and
wrap it in `Semantics(label: ...)` when it needs a label.

### Actions inside loading content

Current loading content may contain an intentional action, such as Cancel. The
outer button stays disabled, but the inner action remains focusable and
accessible:

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  loadingChild: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(semanticsLabel: l10n.savingChanges),
      ),
      TextButton(onPressed: cancelSave, child: Text(l10n.cancel)),
    ],
  ),
  child: Text(l10n.save),
);
```

The package has no cancellation API. `cancelSave` must cancel the
application's operation so the Future returned by `onPressed` completes, and
the owner of any external `loading` must clear it. A Cancel label alone does
not stop loading. On Cupertino, describe the action inside the loading content
rather than with an ancestor `Semantics` label while custom loading content is
shown.

## Custom builders

With `transitionType: TransitionAnimationType.customBuilder`, the builder
receives the effective loading state, the idle content, and the supplied
`loadingChild` unchanged, including `null`. The package adds no default
spinner, no semantics wrapper, and no transition.

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.customBuilder,
  customBuilder: (loading, child, loadingChild) => loading
      ? loadingChild ??
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              semanticsLabel: l10n.savingChanges,
            ),
          )
      : child,
  child: Text(l10n.save),
);
```

A builder that shows only the current state, as above, keeps no inactive
subtree. If a builder retains or animates both states, it owns:

- Sizing of both states. A builder can change the button's size.
- Isolating inactive and outgoing content with `IgnorePointer`,
  `ExcludeFocus`, and `ExcludeSemantics`. Opacity alone does not prevent
  taps, focus, or screen reader access.
- All accessible labels and progress values.

```dart
customBuilder: (loading, child, loadingChild) => Stack(
  alignment: Alignment.center,
  children: [
    IgnorePointer(
      ignoring: loading,
      child: ExcludeFocus(
        excluding: loading,
        child: ExcludeSemantics(
          excluding: loading,
          child: AnimatedOpacity(
            opacity: loading ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: child,
          ),
        ),
      ),
    ),
    if (loading)
      loadingChild ??
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              semanticsLabel: l10n.savingChanges,
            ),
          ),
  ],
),
```

The outer button still owns activation, the loading lock, and disabled
semantics. `AsyncFloatingActionButton.extended` can call the builder
separately for its icon and label slots, so make the builder correct for both.

## Sizing details

- Stack keeps the idle layout. Material stack indicators are centered within
  the whole button, including padding, even for icon-and-label variants with
  asymmetric padding. Cupertino content stays inside native padding and
  alignment. Neither guarantees a fixed size when loading content is larger.
- Animated switcher keeps both sizes in the layout while content fades, then
  animates the resize.
- Icon-and-label buttons scale their icon spacing with text. Extended FAB stack
  transitions keep the icon area; fixed-size FAB variants keep Material's
  constraints.
- The default Cupertino indicator is sized to the button text, so stack
  loading keeps the idle size for text content across native sizes.
- For a stable size, give the button tight constraints and keep loading
  content within them. On Material buttons, set `fixedSize` in `style` (for
  example `ElevatedButton.styleFrom(fixedSize: const Size(160, 48))`), or wrap
  the button in a `SizedBox` with both dimensions; on Cupertino, use the
  `SizedBox`. `minimumSize` is only a lower bound, so larger loading content
  still grows the button. Tight constraints do not shrink content, so size
  `loadingChild` to fit, for example with a `SizedBox.square` spinner or
  short text, or wide content overflows.

## IconButton selection

With a Material 3 theme, every `AsyncIconButton` variant accepts
`isSelected` as a `WidgetStateProperty<bool>?` and an optional `selectedIcon`:

```dart
// In a State object's build method; isFavorite is a bool field.
AsyncIconButton.filled(
  tooltip: l10n.toggleFavorite,
  isSelected: WidgetStatePropertyAll(isFavorite),
  icon: const Icon(Icons.favorite_border),
  selectedIcon: const Icon(Icons.favorite),
  loadingSemanticsLabel: l10n.savingFavorite,
  onPressed: () async {
    await saveFavorite(!isFavorite);
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  },
);
```

The application owns the selection state. Without `selectedIcon`, `icon` is
used in both states.
