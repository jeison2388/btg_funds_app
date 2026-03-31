import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final FundTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubscription = transaction.type == TransactionType.subscription;
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSubscription
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        child: Icon(
          isSubscription ? Icons.add_circle : Icons.remove_circle,
          color: isSubscription ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        transaction.fundName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${transaction.type.label} • ${dateFormatter.format(transaction.date)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (transaction.notificationMethod != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  transaction.notificationMethod!.name == 'email'
                      ? Icons.email_outlined
                      : Icons.sms_outlined,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  'Notificado por ${transaction.notificationMethod!.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: isSubscription
          ? Text(
              '- ${currencyFormatter.format(transaction.amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              '+ Reembolso',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
      isThreeLine: true,
    );
  }
}
