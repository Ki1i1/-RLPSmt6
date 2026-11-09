import 'package:flutter/material.dart';

import '../shared/theme.dart';

/// Widget presentasi yang sama dapat dipakai untuk semua pembacaan sensor.
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  final String label;
  final double value;
  final String unit;
  final String status;

  @override
  Widget build(BuildContext context) {
    // BFF Modul 2 memakai WARN; UI menggunakan WARNING.
    final normalizedStatus = status == 'WARN' ? 'WARNING' : status;
    final Color statusColor;
    final Color backgroundColor;
    final Color textColor;
    final String statusLabel;
    final String message;

    switch (normalizedStatus) {
      case 'OK':
        statusColor = AppColors.primary;
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF166534);
        statusLabel = 'Normal';
        message = 'SYSTEM SECURE';
      case 'WARNING':
        statusColor = AppColors.warning;
        backgroundColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFF92400E);
        statusLabel = 'Peringatan';
        message = 'ACTION REQUIRED';
      case 'DANGER':
        statusColor = AppColors.danger;
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
        statusLabel = 'Kritis';
        message = 'ACTION REQUIRED';
      default:
        statusColor = const Color(0xFF94A3B8);
        backgroundColor = AppColors.background;
        textColor = const Color(0xFF475569);
        statusLabel = 'Belum diketahui';
        message = 'STATUS UNAVAILABLE';
    }

    final reading = value.toStringAsFixed(1);

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$label, $reading $unit, $statusLabel',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(left: BorderSide(color: statusColor, width: 8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          reading,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0x160F172A)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        const Text(
                          'INTEGRITY STATUS',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
