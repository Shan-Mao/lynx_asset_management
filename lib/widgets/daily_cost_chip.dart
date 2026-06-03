import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/strings.dart';

class DailyCostChip extends StatelessWidget {
  const DailyCostChip({super.key, required this.dailyCost});
  final double dailyCost;
  Color get _color { if (dailyCost < 10) return Colors.green.shade100; if (dailyCost < 50) return Colors.orange.shade100; return Colors.red.shade100; }
  Color get _textColor { if (dailyCost < 10) return Colors.green.shade800; if (dailyCost < 50) return Colors.orange.shade800; return Colors.red.shade800; }
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(12)),
      child: Text('${formatCurrency(dailyCost)}${S.detailPerDay}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textColor)));
  }
}
