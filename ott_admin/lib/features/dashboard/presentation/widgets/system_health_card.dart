import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';

class SystemHealthCard extends StatelessWidget {
  final String serviceName;
  final bool isOnline;
  final String latency;

  const SystemHealthCard({
    super.key,
    required this.serviceName,
    required this.isOnline,
    required this.latency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.check_circle_outline : Icons.error_outline,
              color: isOnline ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(isOnline ? 'Operational • $latency' : 'Service Down',
                    style: TextStyle(color: isOnline ? Colors.white38 : Colors.redAccent, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
