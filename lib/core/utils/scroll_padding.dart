import 'package:flutter/material.dart';

/// Dolny padding uwzględniający pasek systemowy i opcjonalnie nawigację aplikacji.
class ScrollPadding {
  static EdgeInsets list(BuildContext context, {bool includeNavBar = false}) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final nav = includeNavBar ? kBottomNavigationBarHeight : 0.0;
    return EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom + nav + 8);
  }
}
