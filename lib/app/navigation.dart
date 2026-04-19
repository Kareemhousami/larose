import 'package:flutter/material.dart';

/// Pops the current route when possible, otherwise replaces it with a fallback.
void popOrGoTo(
  BuildContext context,
  String fallbackRoute, {
  Object? arguments,
}) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  navigator.pushReplacementNamed(fallbackRoute, arguments: arguments);
}
