import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/virtuomate_logo.dart';

enum VButtonVariant { primary, ghost, outline }

/// Matches `virtuomate-mvp/components/ui/v-button.tsx`.
class VButton extends StatelessWidget {
  const VButton({
    required this.title,
    super.key,
    this.icon,
    this.variant = VButtonVariant.primary,
    this.onPressed,
    this.expanded = false,
    this.height = 48,
  });

  final String title;
  final IconData? icon;
  final VButtonVariant variant;
  final VoidCallback? onPressed;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final primaryText = variant == VButtonVariant.primary;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: primaryText
                ? VirtuoMvpColors.primaryTextOnPurple
                : variant == VButtonVariant.ghost
                    ? VirtuoMvpColors.cyan
                    : VirtuoMvpColors.text,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryText
                  ? VirtuoMvpColors.primaryTextOnPurple
                  : VirtuoMvpColors.text,
              fontWeight: primaryText ? FontWeight.w800 : FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );

    Widget button;
    switch (variant) {
      case VButtonVariant.primary:
        button = Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            child: Ink(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                gradient: LinearGradient(
                  colors: disabled
                      ? [
                          VirtuoMvpColors.cyan.withValues(alpha: 0.4),
                          VirtuoMvpColors.purple.withValues(alpha: 0.4),
                        ]
                      : [VirtuoMvpColors.cyan, VirtuoMvpColors.purple],
                ),
                border: Border.all(color: VirtuoMvpColors.stroke2),
              ),
              child: Center(child: child),
            ),
          ),
        );
        break;
      case VButtonVariant.ghost:
        button = Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            child: Ink(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                color: disabled
                    ? VirtuoMvpColors.surface.withValues(alpha: 0.55)
                    : VirtuoMvpColors.surface,
                border: Border.all(color: VirtuoMvpColors.stroke),
              ),
              child: Center(child: child),
            ),
          ),
        );
        break;
      case VButtonVariant.outline:
        button = Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                border: Border.all(color: VirtuoMvpColors.stroke2),
              ),
              child: child,
            ),
          ),
        );
        break;
    }

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Matches `virtuomate-mvp/components/ui/v-card.tsx`.
class VCard extends StatelessWidget {
  const VCard({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VirtuoMvpColors.surface,
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        border: Border.all(color: VirtuoMvpColors.stroke),
      ),
      child: child,
    );
  }
}

/// Matches `virtuomate-mvp/components/ui/v-text-input.tsx`.
class VTextField extends StatelessWidget {
  const VTextField({
    required this.controller,
    super.key,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.hintText,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final lineCount = maxLines ?? 1;
    final multi = !obscureText && lineCount > 1;
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(color: VirtuoMvpColors.text, fontSize: 14),
      cursorColor: VirtuoMvpColors.cyan,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        errorStyle: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11),
        hintText: hintText,
        hintStyle: const TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 14),
      ),
    );
    return Container(
      constraints: BoxConstraints(minHeight: multi ? 100 : 44),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: multi ? 10 : 0),
      alignment: multi ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        color: VirtuoMvpColors.inputFill,
        border: Border.all(color: VirtuoMvpColors.stroke),
      ),
      child: field,
    );
  }
}

/// Matches `virtuomate-mvp/components/ui/top-bar.tsx`.
class MvpTopBar extends StatelessWidget {
  const MvpTopBar({
    super.key,
    this.title,
    this.right,
    this.onBack,
  });

  final String? title;
  final Widget? right;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VirtuoMvpSpacing.lg,
        8,
        VirtuoMvpSpacing.lg,
        10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack ?? () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left, size: 22, color: VirtuoMvpColors.text),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: VirtuoMvpColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
          ),
          SizedBox(
            width: 76,
            child: Align(
              alignment: Alignment.centerRight,
              child: right ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Welcome brand mark — shown once on the welcome screen.
class MvpWelcomeLogo extends StatefulWidget {
  const MvpWelcomeLogo({super.key});

  @override
  State<MvpWelcomeLogo> createState() => _MvpWelcomeLogoState();
}

class _MvpWelcomeLogoState extends State<MvpWelcomeLogo> {
  static var _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      VirtuoMateLogo.precacheWelcome(context);
    }
  }

  @override
  Widget build(BuildContext context) => const VirtuoMateLogo.welcome();
}
