import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_state.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';
import 'package:btg_funds_app/presentation/widgets/transaction_tile.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de transacciones')),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state.status == TransactionsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransactionsStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Error desconocido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TransactionsCubit>()
                        .loadTransactions(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.transactions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Sin transacciones',
              subtitle:
                  'Aún no ha realizado ninguna transacción.\n'
                  'Suscríbase a un fondo para empezar.',
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<TransactionsCubit>().loadTransactions(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return TransactionTile(
                  transaction: state.transactions[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
