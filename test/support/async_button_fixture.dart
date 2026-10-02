import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef LoadingBuilder =
    Widget Function(bool loading, Widget child, Widget? loadingChild);

typedef AsyncButtonBuilder =
    Widget Function({
      required Widget child,
      required FutureOr<void> Function()? onPressed,
      bool loading,
      Widget? loadingChild,
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
      Widget? icon,
      bool loading,
      Widget? loadingChild,
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
      bool loading,
      Widget? loadingChild,
      TransitionAnimationType transitionType,
      Duration animationDuration,
      double minimumChildOpacity,
      LoadingBuilder? customBuilder,
      FocusNode? focusNode,
    });

final asyncButtonBuilders = <String, AsyncButtonBuilder>{
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

AsyncButtonBuilder _withLabel(
  _LabelBuilder builder, {
  Widget? icon = const Icon(Icons.add),
}) =>
    ({
      required child,
      required onPressed,
      loading = false,
      loadingChild,
      transitionType = TransitionAnimationType.stack,
      animationDuration = Durations.medium1,
      minimumChildOpacity = 0.0,
      customBuilder,
      focusNode,
    }) => builder(
      label: child,
      icon: icon,
      onPressed: onPressed,
      loading: loading,
      loadingChild: loadingChild,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      customBuilder: customBuilder,
      focusNode: focusNode,
    );

AsyncButtonBuilder _withIcon(_IconBuilder builder) =>
    ({
      required child,
      required onPressed,
      loading = false,
      loadingChild,
      transitionType = TransitionAnimationType.stack,
      animationDuration = Durations.medium1,
      minimumChildOpacity = 0.0,
      customBuilder,
      focusNode,
    }) => builder(
      icon: child,
      onPressed: onPressed,
      loading: loading,
      loadingChild: loadingChild,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      customBuilder: customBuilder,
      focusNode: focusNode,
    );

Widget buttonHost(Widget button) => MaterialApp(
  home: Scaffold(body: Center(child: button)),
);

Finder get materialButton => find
    .byWidgetPredicate(
      (widget) =>
          widget is ButtonStyleButton ||
          widget is IconButton ||
          widget is FloatingActionButton,
    )
    .first;
