import 'package:flutter/material.dart';

/// Breakpoints for VirtuoMate responsive layouts.
class VirtuoBreakpoints {
  static const double compact = 360;
  static const double tablet = 600;
}

/// Whether the current width is a narrow phone layout.
bool isCompactWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < VirtuoBreakpoints.compact;

/// Whether the current width is tablet or larger.
bool isTabletWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= VirtuoBreakpoints.tablet;

/// Horizontal padding that scales with screen width.
double responsiveHorizontalPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= VirtuoBreakpoints.tablet) return 32;
  if (w < VirtuoBreakpoints.compact) return 12;
  return 16;
}

/// Max content width for centered forms on tablets.
double? contentMaxWidth(BuildContext context) {
  if (!isTabletWidth(context)) return null;
  return 520;
}

/// Wraps [child] with optional max width centering on wide screens.
Widget responsiveContent(BuildContext context, Widget child) {
  final maxW = contentMaxWidth(context);
  if (maxW == null) return child;
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: child,
    ),
  );
}
