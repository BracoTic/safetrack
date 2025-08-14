import 'package:flutter/material.dart';
import '/core/utils/navigation_helper.dart';

const kOrange = Color(0xFFFF5F00);

/// Flecha naranja posicionada arriba-izquierda (para usar dentro de un Stack).
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  final double left;
  final double topInset;

  const AppBackButton({
    super.key,
    this.onTap,
    this.color = kOrange,
    this.left = 12,
    this.topInset = 12,
  });

  @override
  Widget build(BuildContext context) {
    final top = topInset + MediaQuery.of(context).padding.top;
    return Positioned(
      left: left,
      top: top,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 28),
        color: color,
        tooltip: 'Volver',
        onPressed: onTap ?? () => NavigationHelper.irAInicio(context),
      ),
    );
  }
}

/// AppBar minimalista con flecha naranja (cuando NO usas Stack).
class AppBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final Color color;

  const AppBackAppBar({
    super.key,
    this.title,
    this.onBack,
    this.color = kOrange,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: color,
        onPressed: onBack ?? () => NavigationHelper.irAInicio(context),
      ),
      title:
          title != null
              ? Text(title!, style: const TextStyle(color: Colors.white))
              : null,
      centerTitle: false,
    );
  }
}

/// Panel con borde naranja y fondo oscuro (como el del login).
class AppOrangePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double borderWidth;
  final Color background;

  const AppOrangePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 72,
    this.borderWidth = 2,
    this.background = const Color(0xFF1A1D29),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: kOrange, width: borderWidth),
      ),
      padding: padding,
      child: child,
    );
  }
}
