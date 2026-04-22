import 'package:flutter/material.dart';

import '../theme.dart';

class ScaleSelector extends StatelessWidget {
  final int? value;
  final List<String> labels; // 5 items, index 0 = value 1
  final String? lowLabel;
  final String? highLabel;
  final ValueChanged<int> onSelect;

  const ScaleSelector({
    super.key,
    required this.value,
    required this.labels,
    required this.onSelect,
    this.lowLabel,
    this.highLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final n = i + 1;
            final selected = value == n;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 8,
                  right: i == 4 ? 0 : 8,
                ),
                child: _ScaleButton(
                  number: n,
                  label: labels[i],
                  selected: selected,
                  onTap: () => onSelect(n),
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

class _ScaleButton extends StatelessWidget {
  final int number;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScaleButton({
    required this.number,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.08);
    final border = selected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.30);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
