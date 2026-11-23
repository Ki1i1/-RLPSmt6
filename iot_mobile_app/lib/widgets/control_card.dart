import 'package:flutter/material.dart';

import '../shared/theme.dart';

class ControlCard extends StatelessWidget {
  const ControlCard({
    super.key,
    required this.isOn,
    this.onToggle,
    this.hasStatus = true,
  });

  final bool isOn;
  final VoidCallback? onToggle;
  final bool hasStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            onToggle == null ? 'Status Lampu' : 'Kendali Lampu',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isOn
                        ? const Color(0xFFFFFBEB)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    size: 28,
                    color: isOn ? AppColors.warning : const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  !hasStatus
                      ? 'Status lampu belum tersedia'
                      : isOn
                      ? 'Lampu ON'
                      : 'Lampu OFF',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Semantics(
                label: onToggle == null ? 'Status lampu' : 'Kendali lampu',
                child: Switch(
                  key: const ValueKey('light-switch'),
                  value: isOn,
                  onChanged: onToggle == null ? null : (_) => onToggle!(),
                  activeThumbColor: const Color(0xFF92400E),
                  activeTrackColor: const Color(0xFFFDE68A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
