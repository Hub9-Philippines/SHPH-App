import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class InvoiceLineItem {
  const InvoiceLineItem({required this.label, required this.amount});
  final String label;
  final double amount;
}

class InvoiceLineItems extends StatelessWidget {
  const InvoiceLineItems({
    super.key,
    required this.items,
    this.total,
  });

  final List<InvoiceLineItem> items;
  final double? total;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final effectiveTotal = total ?? items.fold<double>(0, (sum, i) => sum + i.amount);
    final hasExplicitTotal = items.any((i) => i.label.toLowerCase() == 'total');
    final displayItems = hasExplicitTotal ? items : [
      ...items,
      InvoiceLineItem(label: 'Total due', amount: effectiveTotal),
    ];

    return Column(
      children: displayItems.map((item) {
        final isTotal = item.label.toLowerCase().contains('total');
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: isTotal ? BoxDecoration(
            border: Border(top: BorderSide(color: theme.border)),
          ) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                  color: isTotal ? theme.primaryText : theme.secondaryText,
                ),
              ),
              Text(
                'P ${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                  color: isTotal ? theme.primary : theme.primaryText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
