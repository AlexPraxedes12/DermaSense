import 'package:flutter/material.dart';

import 'package:derma_sense/core/theme/app_colors.dart';

/// Tarjeta base con esquinas redondeadas, borde sutil y sombra ligera.
///
/// Es el contenedor visual estándar de la app: paneles, métricas y secciones lo
/// reutilizan para mantener una apariencia consistente.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  /// Contenido de la tarjeta.
  final Widget child;

  /// Relleno interno (por defecto 20 px en todos los lados).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
