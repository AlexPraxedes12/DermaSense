import 'package:flutter/material.dart';

/// Punto luminoso de color usado para señalizar el estado de un sensor de
/// temperatura (verde / naranja / rojo) con un suave halo.
class TemperatureDot extends StatelessWidget {
  const TemperatureDot({super.key, required this.color});

  /// Color del punto y de su halo.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withAlpha(76), blurRadius: 8, spreadRadius: 1),
        ],
      ),
    );
  }
}
