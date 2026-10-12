import 'package:flutter/material.dart';

class SimulatedErrorSwitch extends StatelessWidget {
  final bool isSimulatingError;
  final VoidCallback onToggle;

  const SimulatedErrorSwitch({
    super.key,
    required this.isSimulatingError,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isSimulatingError
          ? 'Simulate Error is ON (Tap to turn OFF)'
          : 'Simulate Error is OFF (Tap to turn ON)',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSimulatingError
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSimulatingError
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSimulatingError
                    ? Icons.bug_report_rounded
                    : Icons.bug_report_outlined,
                size: 16,
                color: isSimulatingError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                isSimulatingError ? 'Error ON' : 'Mock Error',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSimulatingError
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
