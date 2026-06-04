import 'package:flutter/material.dart';

/// Runtime bootstrap flags (actual Firebase/API connection), not compile-time defines.
class VirtuoMateRuntime extends InheritedWidget {
  const VirtuoMateRuntime({
    required this.firebaseEnabled,
    required this.useBackendApi,
    this.bootstrapWarning,
    required super.child,
    super.key,
  });

  final bool firebaseEnabled;
  final bool useBackendApi;
  final String? bootstrapWarning;

  static VirtuoMateRuntime of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VirtuoMateRuntime>();
    assert(scope != null, 'VirtuoMateRuntime is not available in the widget tree.');
    return scope!;
  }

  static VirtuoMateRuntime? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VirtuoMateRuntime>();
  }

  @override
  bool updateShouldNotify(VirtuoMateRuntime oldWidget) {
    return firebaseEnabled != oldWidget.firebaseEnabled ||
        useBackendApi != oldWidget.useBackendApi ||
        bootstrapWarning != oldWidget.bootstrapWarning;
  }
}
