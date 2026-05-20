import 'package:flutter/material.dart';

class ReportUtils {
  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NAPRAWIONE':
        return Colors.green;
      case 'W_TRAKCIE':
        return Colors.orange;
      case 'ODRZUCONE':
      case 'ANULOWANE':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  static String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'NAPRAWIONE':
        return 'Naprawione';
      case 'W_TRAKCIE':
        return 'W trakcie';
      case 'ODRZUCONE':
        return 'Odrzucone';
      case 'ANULOWANE':
        return 'Anulowane';
      default:
        return 'Nowe';
    }
  }

  static Color parsePinColor(String pinColor) {
    final hex = pinColor.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.red;
  }

  static IconData categoryIcon(String iconName) {
    switch (iconName) {
      case 'road':
        return Icons.add_road;
      case 'light':
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'trash':
      case 'delete':
        return Icons.delete_outline;
      case 'park':
        return Icons.park_outlined;
      case 'help':
        return Icons.help_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }
}
