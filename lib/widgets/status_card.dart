import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool locked;
  final String message;

  const StatusCard({
    super.key,
    required this.locked,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final icon = locked ? Icons.lock : Icons.lock_open;
    final color = locked ? Colors.redAccent : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
