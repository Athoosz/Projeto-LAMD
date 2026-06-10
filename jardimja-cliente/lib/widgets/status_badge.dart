import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'pendente':
        return const Color(0xFFFFF9C4);
      case 'aceito':
        return const Color(0xFFBBDEFB);
      case 'em andamento':
        return const Color(0xFFE1BEE7);
      case 'concluido':
        return const Color(0xFFC8E6C9);
      case 'recusado':
        return const Color(0xFFFFCDD2);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'pendente':
        return const Color(0xFFF57F17);
      case 'aceito':
        return const Color(0xFF1565C0);
      case 'em andamento':
        return const Color(0xFF6A1B9A);
      case 'concluido':
        return const Color(0xFF2E7D32);
      case 'recusado':
        return const Color(0xFFC62828);
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getTextColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

