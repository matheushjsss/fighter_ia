import 'package:fighter_ia/util/app_colors.dart';
import 'package:flutter/material.dart';

/// Selo pequeno da organização (UFC, PFL, B...).
class FcMiniBadge extends StatelessWidget {
  final String text;
  const FcMiniBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
