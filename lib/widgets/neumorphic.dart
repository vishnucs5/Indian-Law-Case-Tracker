import 'package:flutter/material.dart';
import '../theme/legal_theme.dart';

enum NeuShape { flat, pressed }

class NeuContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final NeuShape shape;
  final VoidCallback? onTap;

  const NeuContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = LegalRadius.lg,
    this.color,
    this.shape = NeuShape.flat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? LegalColors.surface;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shape == NeuShape.pressed
            ? [
                BoxShadow(
                  color: LegalColors.insetShadow,
                  offset: const Offset(3, 3),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: LegalColors.highlight.withValues(alpha: 0.95),
                  offset: const Offset(-3, -3),
                  blurRadius: 8,
                  spreadRadius: -3,
                ),
              ]
            : [
                BoxShadow(
                  color: LegalColors.shadow,
                  offset: const Offset(8, 8),
                  blurRadius: 18,
                ),
                BoxShadow(
                  color: LegalColors.highlight.withValues(alpha: 0.95),
                  offset: const Offset(-8, -8),
                  blurRadius: 18,
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool selected;
  final String? tooltip;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.selected = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = NeuContainer(
      shape: selected ? NeuShape.pressed : NeuShape.flat,
      radius: 16,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Icon(
        icon,
        size: 22,
        color: color ?? (selected ? LegalColors.gold : LegalColors.textMuted),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class NeuSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const NeuSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LegalColors.textPrimary,
                  ),
            ),
          ),
          if (trailing != null)
            NeuContainer(
              shape: NeuShape.pressed,
              radius: LegalRadius.pill,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                trailing!,
                style: const TextStyle(
                  color: LegalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NeuEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const NeuEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeuContainer(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuContainer(
              shape: NeuShape.pressed,
              radius: 24,
              padding: const EdgeInsets.all(18),
              child: Icon(icon, size: 38, color: LegalColors.gold),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LegalColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: LegalColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class NeuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  final bool isPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeuButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.radius = LegalRadius.lg,
    this.isPressed = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      onTap: onTap,
      color: color,
      radius: radius,
      shape: isPressed ? NeuShape.pressed : NeuShape.flat,
      padding: padding,
      margin: margin,
      child: Center(
        child: child,
      ),
    );
  }
}

