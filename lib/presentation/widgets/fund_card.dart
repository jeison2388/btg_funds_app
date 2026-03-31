import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/presentation/widgets/category_chip.dart';

class FundCard extends StatelessWidget {
  final Fund fund;
  final bool isSubscribed;
  final VoidCallback? onSubscribe;

  const FundCard({
    super.key,
    required this.fund,
    this.isSubscribed = false,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fund.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CategoryChip(category: fund.category),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Monto mínimo: ${formatter.format(fund.minimumAmount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isSubscribed
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Ya suscrito'),
                    )
                  : ElevatedButton.icon(
                      onPressed: onSubscribe,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Suscribirse'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
