import 'package:flutter/material.dart';

class DayPill extends StatelessWidget {
  final String line1;
  final String line2;
  final bool selected;
  final VoidCallback onTap;

  const DayPill({
    super.key,
    required this.line1,
    required this.line2,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF8B6CF3) : const Color(0xFFFFFFFF);
    final fg = selected ? Colors.white : const Color(0xFF2A2A2A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 64,
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE6E6E6),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              line1,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),

            Text(
              line2,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF9AA0A6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
