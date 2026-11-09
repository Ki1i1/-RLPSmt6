import 'package:flutter/material.dart';

import '../shared/theme.dart';

/// State lampu dimiliki Provider; widget hanya menerima nilai dan callback.
class ControlCard extends StatelessWidget {
  const ControlCard({super.key, required this.isOn, required this.onToggle});

  final bool isOn;
  final VoidCallback onToggle;

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
          const Text(
            'Kendali Lampu',
            style: TextStyle(
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
                  isOn ? 'Lampu ON' : 'Lampu OFF',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Semantics(
                label: 'Kendali lampu',
                child: Switch(
                  key: const ValueKey('light-switch'),
                  value: isOn,
                  onChanged: (_) => onToggle(),
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
