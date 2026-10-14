import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/loading_transition.dart';

/// The default loading transition duration, shared with the adaptive button.
const asyncCupertinoAnimationDuration = Duration(milliseconds: 200);

/// The default disabled background of the plain variant.
const Color asyncCupertinoPlainDisabledColor =
    CupertinoColors.quaternarySystemFill;

/// The default disabled background of the filled and tinted variants.
const Color asyncCupertinoFilledDisabledColor =
    CupertinoColors.tertiarySystemFill;

enum _AsyncCupertinoButtonVariant { plain, filled, tinted }

/// A native [CupertinoButton] with external and async loading states.
///
/// Effective loading is [loading], a [controller] request, or a pending
/// [onPressed] or [onError].
/// A pending peer in the nearest [AsyncButtonGroup] also disables it without
/// loading content, unless [excludeFromGroup] is true.
/// Loading disables outer activation; built-in transitions exclude inactive
/// content from pointer input, focus, and semantics. Unhandled errors propagate
/// with their original stack trace. Return or await all work to be tracked.
/// Disposal does not cancel that work or its captured error handler.
///
/// Works under [CupertinoApp] without a Material ancestor. Native sizes,
/// padding, colors, focus, and press feedback are preserved. Larger
/// [loadingChild] content can affect layout within native and parent
/// constraints. [customBuilder] owns sizing and all content interaction, focus,
/// and semantics.
class AsyncCupertinoButton extends StatefulWidget {
  /// Creates an iOS-style button with tracked async activation.
  ///
  /// With both [onPressed] and [onLongPress] null, the button is disabled.
  const AsyncCupertinoButton({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.foregroundColor,
    this.disabledColor = asyncCupertinoPlainDisabledColor,
    this.minimumSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.onLongPress,
    this.animationDuration = asyncCupertinoAnimationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    super.key,
  }) : _variant = _AsyncCupertinoButtonVariant.plain,
       assert(
         pressedOpacity == null ||
             (pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
       ),
       assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       );

  /// Creates an iOS-style button with a filled background with tracked
  /// async activation.
  ///
  /// With both [onPressed] and [onLongPress] null, the button is disabled.
  const AsyncCupertinoButton.filled({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.foregroundColor,
    this.disabledColor = asyncCupertinoFilledDisabledColor,
    this.minimumSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.onLongPress,
    this.animationDuration = asyncCupertinoAnimationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    super.key,
  }) : _variant = _AsyncCupertinoButtonVariant.filled,
       assert(
         pressedOpacity == null ||
             (pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
       ),
       assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       );

  /// Creates an iOS-style button with a tinted background with tracked
  /// async activation.
  ///
  /// With both [onPressed] and [onLongPress] null, the button is disabled.
  const AsyncCupertinoButton.tinted({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.foregroundColor,
    this.disabledColor = asyncCupertinoFilledDisabledColor,
    this.minimumSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.onLongPress,
    this.animationDuration = asyncCupertinoAnimationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    super.key,
  }) : _variant = _AsyncCupertinoButtonVariant.tinted,
       assert(
         pressedOpacity == null ||
             (pressedOpacity >= 0.0 && pressedOpacity <= 1.0),
       ),
       assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       );

  /// The idle button content.
  final Widget child;

  /// The synchronous or asynchronous activation callback.
  ///
  /// Return or await async work to keep loading until it and [onError] finish.
  /// Null disables activation unless [onLongPress] is supplied. Unhandled
  /// errors propagate with their original stack trace. Unreturned Futures are
  /// untracked.
  final FutureOr<void> Function()? onPressed;

  /// The optional handler that explicitly consumes activation errors.
  ///
  /// Loading stays active until it finishes. Handler failures propagate without
  /// invoking it again. Captured at activation and called even after disposal;
  /// check your own lifecycle before using captured state or context. See
  /// [AsyncButtonErrorHandler] for the shared policy.
  final AsyncButtonErrorHandler? onError;

  /// An optional controller that observes and requests loading.
  ///
  /// Its [AsyncButtonController.loading] request and pending operation both
  /// add to effective loading. The pending operation may have started on an
  /// earlier button that used the same controller. The caller owns and disposes
  /// the controller.
  final AsyncButtonController? controller;

  /// Whether this button ignores the nearest [AsyncButtonGroup].
  ///
  /// Defaults to false. Excluded buttons, such as a Cancel action, stay
  /// available while a member operation is pending and do not block members.
  final bool excludeFromGroup;

  /// Whether the application requests loading, independently of pending work.
  ///
  /// Effective loading combines this flag, any [controller] request, and a
  /// pending [onPressed] or [onError]. Clearing this flag does not unlock a
  /// pending callback or error handler; completing those callbacks does not
  /// clear this flag.
  final bool loading;

  /// Optional loading content, replacing the default
  /// [CupertinoActivityIndicator].
  ///
  /// The default indicator is sized to the native button text, so stack loading
  /// keeps the idle size for text content. Custom content owns its accessible
  /// labels and may change the button size.
  /// A custom builder receives this value unchanged, including null.
  final Widget? loadingChild;

  /// The optional localized accessible label for the default indicator.
  ///
  /// Defaults to null, with no fallback or live announcement. Ignored with
  /// [loadingChild] or [TransitionAnimationType.customBuilder].
  final String? loadingSemanticsLabel;

  /// The native button size, defaulting to [CupertinoButtonSize.large].
  final CupertinoButtonSize sizeStyle;

  /// The native padding around the content, resolved by [CupertinoButton].
  final EdgeInsetsGeometry? padding;

  /// The native background color, with theme-derived filled and tinted
  /// defaults.
  final Color? color;

  /// The native foreground color, also used by the default loading indicator.
  ///
  /// When null, the indicator uses [CupertinoThemeData.primaryColor] for every
  /// variant. Loading disables the native button, so filled and tinted buttons
  /// show [disabledColor]; an explicit color should remain readable on it.
  final Color? foregroundColor;

  /// The native disabled background color, with variant-specific defaults.
  ///
  /// Filled and tinted buttons also show it while loading.
  final Color disabledColor;

  /// The native minimum button size.
  ///
  /// Uses the current native API rather than the deprecated `minSize` argument.
  final Size? minimumSize;

  /// The opacity while pressed, defaulting to 0.4; null disables press fading.
  final double? pressedOpacity;

  /// The native corner radius when the button has a background.
  final BorderRadius? borderRadius;

  /// The native content alignment, defaulting to [Alignment.center].
  final AlignmentGeometry alignment;

  /// The native keyboard focus highlight color.
  final Color? focusColor;

  /// The native focus node.
  final FocusNode? focusNode;

  /// Called when native focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Whether the native button requests initial focus.
  final bool autofocus;

  /// The native mouse cursor, including state-dependent cursors.
  final MouseCursor? mouseCursor;

  /// The synchronous long-press callback, blocked while loading.
  ///
  /// Keeps an idle button enabled when [onPressed] is null and does not start
  /// internal loading. Errors retain normal synchronous callback behavior.
  final VoidCallback? onLongPress;

  /// The loading transition duration, defaulting to 200 milliseconds.
  final Duration animationDuration;

  /// The idle content opacity during stack loading, defaulting to 0.0.
  ///
  /// Partially visible inactive content stays isolated from interaction,
  /// focus, and semantics in built-in transitions.
  final double minimumChildOpacity;

  /// The loading transition, defaulting to [TransitionAnimationType.stack].
  final TransitionAnimationType transitionType;

  /// Required presentation builder for [TransitionAnimationType.customBuilder].
  ///
  /// Receives effective loading, idle content, and nullable [loadingChild]. No
  /// default indicator or content semantics wrapper is supplied. Owns sizing
  /// and inactive or outgoing content isolation; outer activation stays locked.
  final Widget Function(bool loading, Widget child, Widget? loadingChild)?
  customBuilder;

  final _AsyncCupertinoButtonVariant _variant;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    debugFillAsyncButtonProperties(
      properties,
      onPressed: onPressed,
      onError: onError,
      controller: controller,
      excludeFromGroup: excludeFromGroup,
      loading: loading,
      loadingSemanticsLabel: loadingSemanticsLabel,
      transitionType: transitionType,
      animationDuration: animationDuration,
      defaultAnimationDuration: asyncCupertinoAnimationDuration,
      minimumChildOpacity: minimumChildOpacity,
      customBuilder: customBuilder,
    );
    debugFillAsyncButtonInteractionProperties(
      properties,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      mouseCursor: mouseCursor,
      onFocusChange: onFocusChange,
    );
    properties
      ..add(EnumProperty<_AsyncCupertinoButtonVariant>('variant', _variant))
      ..add(
        EnumProperty<CupertinoButtonSize>(
          'sizeStyle',
          sizeStyle,
          defaultValue: CupertinoButtonSize.large,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'padding',
          padding,
          defaultValue: null,
        ),
      )
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(
        ColorProperty('foregroundColor', foregroundColor, defaultValue: null),
      )
      ..add(
        ColorProperty(
          'disabledColor',
          disabledColor,
          defaultValue: _variant == _AsyncCupertinoButtonVariant.plain
              ? asyncCupertinoPlainDisabledColor
              : asyncCupertinoFilledDisabledColor,
        ),
      )
      ..add(
        DiagnosticsProperty<Size>(
          'minimumSize',
          minimumSize,
          defaultValue: null,
        ),
      )
      ..add(DoubleProperty('pressedOpacity', pressedOpacity, defaultValue: 0.4))
      ..add(
        DiagnosticsProperty<BorderRadius>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<AlignmentGeometry>(
          'alignment',
          alignment,
          defaultValue: Alignment.center,
        ),
      )
      ..add(ColorProperty('focusColor', focusColor, defaultValue: null));
  }

  @override
  State<AsyncCupertinoButton> createState() => _AsyncCupertinoButtonState();
}

class _AsyncCupertinoButtonState extends State<AsyncCupertinoButton>
    with AsyncButtonState<AsyncCupertinoButton> {
  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  @override
  AsyncButtonErrorHandler? get asyncOnError => widget.onError;

  @override
  AsyncButtonController? get asyncController => widget.controller;

  @override
  bool get excludeFromGroup => widget.excludeFromGroup;

  void _handleLongPress() {
    if (!mounted || isLocked) return;
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    // A constructor tear-off type would spell out every native parameter.
    // ignore: specify_nonobvious_local_variable_types
    final buttonBuilder = switch (widget._variant) {
      _AsyncCupertinoButtonVariant.plain => CupertinoButton.new,
      _AsyncCupertinoButtonVariant.filled => CupertinoButton.filled,
      _AsyncCupertinoButtonVariant.tinted => CupertinoButton.tinted,
    };

    // Native CupertinoButton supplies the role and gesture actions but omits an
    // enabled-state flag. Keep the shared disabled accessibility contract.
    return _CupertinoButtonSemantics(
      enabled:
          !isLocked && (widget.onPressed != null || widget.onLongPress != null),
      // Custom loading content may keep an intentional action, such as Cancel.
      isolateContentActions:
          isLoading &&
          (widget.loadingChild != null ||
              widget.transitionType == TransitionAnimationType.customBuilder),
      child: buttonBuilder(
        onPressed: unlockedHandler(widget.onPressed, handlePressed),
        onLongPress: unlockedHandler(widget.onLongPress, _handleLongPress),
        sizeStyle: widget.sizeStyle,
        padding: widget.padding,
        color: widget.color,
        foregroundColor: widget.foregroundColor,
        disabledColor: widget.disabledColor,
        minimumSize: widget.minimumSize,
        pressedOpacity: widget.pressedOpacity,
        borderRadius: widget.borderRadius,
        alignment: widget.alignment,
        focusColor: widget.focusColor,
        focusNode: widget.focusNode,
        onFocusChange: widget.onFocusChange,
        autofocus: widget.autofocus,
        mouseCursor: widget.mouseCursor,
        child: widget.transitionType == TransitionAnimationType.customBuilder
            ? widget.customBuilder?.call(
                    isLoading,
                    widget.child,
                    widget.loadingChild,
                  ) ??
                  widget.child
            : LoadingTransition(
                child: widget.child,
                loadingChild:
                    (widget.loadingChild == null
                        ? null
                        : Semantics(
                            container: true,
                            child: widget.loadingChild,
                          )) ??
                    _CupertinoLoadingIndicator(
                      foregroundColor: widget.foregroundColor,
                      loadingSemanticsLabel: widget.loadingSemanticsLabel,
                    ),
                isLoading: isLoading,
                transitionType: widget.transitionType,
                animationDuration: widget.animationDuration,
                minimumChildOpacity: widget.minimumChildOpacity,
              ),
      ),
    );
  }
}

class _CupertinoLoadingIndicator extends StatelessWidget {
  const _CupertinoLoadingIndicator({
    required this.foregroundColor,
    required this.loadingSemanticsLabel,
  });

  // CupertinoActivityIndicator's default, used without a positive text size.
  static const double _defaultRadius = 10.0;

  final Color? foregroundColor;
  final String? loadingSemanticsLabel;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ColorProperty('foregroundColor', foregroundColor, defaultValue: null),
      )
      ..add(
        StringProperty(
          'loadingSemanticsLabel',
          loadingSemanticsLabel,
          defaultValue: null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Loading disables the native button, so filled and tinted backgrounds use
    // disabledColor. The contrasting color can disappear on that light fill.
    final Color color =
        foregroundColor ?? CupertinoTheme.of(context).primaryColor;
    // Match the native text size so stack loading keeps the idle text layout.
    // The indicator requires a positive radius, which zero scaling would break.
    final double? fontSize = DefaultTextStyle.of(context).style.fontSize;
    final double diameter = fontSize == null
        ? 0.0
        : MediaQuery.textScalerOf(context).scale(fontSize);

    return Semantics(
      label: loadingSemanticsLabel,
      child: CupertinoActivityIndicator(
        color: CupertinoDynamicColor.resolve(color, context),
        radius: diameter > 0 ? diameter / 2 : _defaultRadius,
      ),
    );
  }
}

// CupertinoButton's gesture recognizer advertises a tap even when disabled.
// Like the native button, stay mergeable so ancestor labels and hints describe
// it, and block disabled actions through the subtree. Blocking propagates to
// every descendant, so current custom loading content instead gets an outer
// boundary that blocks only the assembled button node.
class _CupertinoButtonSemantics extends SingleChildRenderObjectWidget {
  const _CupertinoButtonSemantics({
    required this.enabled,
    required this.isolateContentActions,
    required super.child,
  });

  final bool enabled;
  final bool isolateContentActions;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _describeSemantics(properties, enabled, isolateContentActions);
  }

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCupertinoButtonSemantics(
        enabled: enabled,
        isolateContentActions: isolateContentActions,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCupertinoButtonSemantics renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..isolateContentActions = isolateContentActions;
  }
}

class _RenderCupertinoButtonSemantics extends RenderProxyBox {
  _RenderCupertinoButtonSemantics({
    required this._enabled,
    required this._isolateContentActions,
  });

  bool _enabled;
  bool _isolateContentActions;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    markNeedsSemanticsUpdate();
  }

  bool get isolateContentActions => _isolateContentActions;

  set isolateContentActions(bool value) {
    if (value == _isolateContentActions) return;
    _isolateContentActions = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _describeSemantics(properties, enabled, isolateContentActions);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = _isolateContentActions
      ..isEnabled = _enabled
      ..isBlockingUserActions = !_enabled && !_isolateContentActions;
  }

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    super.assembleSemanticsNode(
      node,
      config.copy()..isBlockingUserActions = !_enabled,
      children,
    );
  }
}

void _describeSemantics(
  DiagnosticPropertiesBuilder properties,
  bool enabled,
  bool isolateContentActions,
) {
  properties
    ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
    ..add(
      FlagProperty(
        'isolateContentActions',
        value: isolateContentActions,
        ifTrue: 'isolates content actions',
      ),
    );
}
