import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_state.dart';
import 'package:btg_funds_app/presentation/widgets/btg_paginated_table.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';

@RoutePage()
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TransactionHistoryView();
  }
}

class _TransactionHistoryView extends StatelessWidget {
  const _TransactionHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es');
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == TransactionsStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'Error desconocido'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TransactionsCubit>().loadTransactions(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state.filteredTransactions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Sin resultados',
            subtitle: 'No hay transacciones que coincidan con la búsqueda.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<TransactionsCubit>().loadTransactions(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              BtgPaginatedTable<FundTransaction>(
                items: state.filteredTransactions,
                columns: [
                  BtgTableColumn<FundTransaction>(
                    label: 'Fondo',
                    flex: 2.3,
                    cellBuilder: (tx) => Text(tx.fundName),
                  ),
                  BtgTableColumn<FundTransaction>(
                    label: 'Tipo',
                    flex: 1.4,
                    cellBuilder: (tx) => Text(
                      tx.type == TransactionType.subscription
                          ? 'Suscripción'
                          : 'Cancelación',
                    ),
                  ),
                  BtgTableColumn<FundTransaction>(
                    label: 'Monto',
                    flex: 1.3,
                    cellBuilder: (tx) => Text(currencyFormatter.format(tx.amount)),
                  ),
                  BtgTableColumn<FundTransaction>(
                    label: 'Notificación',
                    flex: 1.3,
                    cellBuilder: (tx) => Text(tx.notificationMethod?.label ?? '-'),
                  ),
                  BtgTableColumn<FundTransaction>(
                    label: 'Fecha',
                    flex: 1.5,
                    cellBuilder: (tx) => Text(dateFormatter.format(tx.date)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
