import 'package:flutter/material.dart';

import '../theme.dart';

class NpsSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onSelect;
  final String? lowLabel;
  final String? highLabel;

  const NpsSelector({
    super.key,
    required this.value,
    required this.onSelect,
    this.lowLabel,
    this.highLabel,
  });

  Color _colorFor(int n) {
    // 0 = red, 10 = green.
    final t = n / 10.0;
    return Color.lerp(const Color(0xFFE74C3C), const Color(0xFF2ECC71), t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (i) {
            final selected = value == i;
            final base = _colorFor(i);
            final bg = selected ? base : base.withValues(alpha: 0.25);
            final borderColor = selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.20);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 6,
                  right: i == 10 ? 0 : 6,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: base.withValues(alpha: 0.6),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : const [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$i',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (lowLabel != null && highLabel != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lowLabel!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 18)),
              Text(highLabel!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 18)),
            ],
          ),
        ],
      ],
    );
  }
}
