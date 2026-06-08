import 'package:city_issues/dataconnect_generated/default.dart';
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

  static int upvoteCount(List<GetReportsReportsUpvotesOnReport> upvotes) {
    return upvotes.where((upvote) => upvote.user.id.isNotEmpty).length;
  }

  static bool userHasUpvoted(
    List<GetReportsReportsUpvotesOnReport> upvotes,
    String? userId,
  ) {
    if (userId == null) return false;
    return upvotes.any(
      (upvote) => upvote.user.id.isNotEmpty && upvote.user.id == userId,
    );
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
