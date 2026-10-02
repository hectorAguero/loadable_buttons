import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef LoadingBuilder =
    Widget Function(bool loading, Widget child, Widget? loadingChild);

typedef AsyncButtonBuilder =
    Widget Function({
      required Widget child,
      required FutureOr<void> Function()? onPressed,
      AsyncButtonErrorHandler? onError,
      bool loading,
      Widget? loadingChild,
      String? loadingSemanticsLabel,
      TransitionAnimationType transitionType,
      Duration animationDuration,
      double minimumChildOpacity,
      LoadingBuilder? customBuilder,
      FocusNode? focusNode,
    });

typedef _LabelBuilder =
    Widget Function({
      required Widget label,
      required FutureOr<void> Function()? onPressed,
      AsyncButtonErrorHandler? onError,
      Widget? icon,
      bool loading,
      Widget? loadingChild,
      String? loadingSemanticsLabel,
      TransitionAnimationType transitionType,
      Duration animationDuration,
      double minimumChildOpacity,
      LoadingBuilder? customBuilder,
      FocusNode? focusNode,
    });

typedef _IconBuilder =
    Widget Function({
      required Widget icon,
      required FutureOr<void> Function()? onPressed,
      WidgetStateProperty<bool>? isSelected,
      Widget? selectedIcon,
      AsyncButtonErrorHandler? onError,
      bool loading,
      Widget? loadingChild,
      String? loadingSemanticsLabel,
      TransitionAnimationType transitionType,
      Duration animationDuration,
      double minimumChildOpacity,
      LoadingBuilder? customBuilder,
      FocusNode? focusNode,
    });

final asyncButtonBuilders = <String, AsyncButtonBuilder>{
  'Cupertino': AsyncCupertinoButton.new,
  'Cupertino.filled': AsyncCupertinoButton.filled,
  'Cupertino.tinted': AsyncCupertinoButton.tinted,
  'Elevated': AsyncElevatedButton.new,
  'Elevated.icon': _withLabel(AsyncElevatedButton.icon),
  'Filled': AsyncFilledButton.new,
  'Filled.icon': _withLabel(AsyncFilledButton.icon),
  'Filled.tonal': AsyncFilledButton.tonal,
  'Filled.tonalIcon': _withLabel(AsyncFilledButton.tonalIcon),
  'Outlined': AsyncOutlinedButton.new,
  'Outlined.icon': _withLabel(AsyncOutlinedButton.icon),
  'Text': AsyncTextButton.new,
  'Text.icon': _withLabel(AsyncTextButton.icon),
  'Icon': _withIcon(AsyncIconButton.new),
  'Icon.filled': _withIcon(AsyncIconButton.filled),
  'Icon.filledTonal': _withIcon(AsyncIconButton.filledTonal),
  'Icon.outlined': _withIcon(AsyncIconButton.outlined),
  'Floating action': AsyncFloatingActionButton.new,
  'Floating action.small': AsyncFloatingActionButton.small,
  'Floating action.large': AsyncFloatingActionButton.large,
  // The icon's keyed layout and transitions have a separate owner in #12.
  'Floating action.extended': _withLabel(
    AsyncFloatingActionButton.extended,
    icon: null,
  ),
};

// Include both factory branches without multiplying unrelated contract tests.
final asyncButtonConstructorBuilders = <String, AsyncButtonBuilder>{
  ...asyncButtonBuilders,
  'Elevated.icon without icon': _withLabel(
    AsyncElevatedButton.icon,
    icon: null,
  ),
  'Filled.icon without icon': _withLabel(AsyncFilledButton.icon, icon: null),
  'Filled.tonalIcon without icon': _withLabel(
    AsyncFilledButton.tonalIcon,
    icon: null,
  ),
  'Outlined.icon without icon': _withLabel(
    AsyncOutlinedButton.icon,
    icon: null,
  ),
  'Text.icon without icon': _withLabel(AsyncTextButton.icon, icon: null),
  'Floating action.extended with icon': _withLabel(
    AsyncFloatingActionButton.extended,
  ),
};

// Selected IconButton content takes a separate indicator forwarding path.
final asyncButtonSemanticsBuilders = <String, AsyncButtonBuilder>{
  ...asyncButtonConstructorBuilders,
  'Icon selected': _withIcon(AsyncIconButton.new, selected: true),
  'Icon.filled selected': _withIcon(AsyncIconButton.filled, selected: true),
  'Icon.filledTonal selected': _withIcon(
    AsyncIconButton.filledTonal,
    selected: true,
  ),
  'Icon.outlined selected': _withIcon(AsyncIconButton.outlined, selected: true),
};

AsyncButtonBuilder _withLabel(
  _LabelBuilder builder, {
  Widget? icon = const Icon(Icons.add),
}) =>
    ({
      required child,
      required onPressed,
      onError,
      loading = false,
      loadingChild,
      loadingSemanticsLabel,
      transitionType = TransitionAnimationType.stack,
      animationDuration = Durations.medium1,
      minimumChildOpacity = 0.0,
      customBuilder,
      focusNode,
    }) => builder(
      label: child,
      icon: icon,
      onPressed: onPressed,
      onError: onError,
      loading: loading,
      loadingChild: loadingChild,
      loadingSemanticsLabel: loadingSemanticsLabel,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      customBuilder: customBuilder,
      focusNode: focusNode,
    );

AsyncButtonBuilder _withIcon(_IconBuilder builder, {bool selected = false}) =>
    ({
      required child,
      required onPressed,
      onError,
      loading = false,
      loadingChild,
      loadingSemanticsLabel,
      transitionType = TransitionAnimationType.stack,
      animationDuration = Durations.medium1,
      minimumChildOpacity = 0.0,
      customBuilder,
      focusNode,
    }) => builder(
      icon: child,
      isSelected: selected ? const WidgetStatePropertyAll(true) : null,
      selectedIcon: selected
          ? const Icon(Icons.check, semanticLabel: 'Selected')
          : null,
      onPressed: onPressed,
      onError: onError,
      loading: loading,
      loadingChild: loadingChild,
      loadingSemanticsLabel: loadingSemanticsLabel,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      customBuilder: customBuilder,
      focusNode: focusNode,
    );

Widget buttonHost(Widget button) => button is AsyncCupertinoButton
    ? cupertino.CupertinoApp(
        home: cupertino.CupertinoPageScaffold(child: Center(child: button)),
      )
    : MaterialApp(
        home: Scaffold(body: Center(child: button)),
      );

Finder get nativeButton => find
    .byWidgetPredicate(
      (widget) =>
          widget is cupertino.CupertinoButton ||
          widget is ButtonStyleButton ||
          widget is IconButton ||
          widget is FloatingActionButton,
    )
    .first;

Finder get defaultLoadingIndicator => find.byWidgetPredicate(
  (widget) =>
      widget is CircularProgressIndicator ||
      widget is cupertino.CupertinoActivityIndicator,
);
