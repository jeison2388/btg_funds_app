import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/utils/app_feedback.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/widgets/btg_paginated_table.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';

@RoutePage()
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PortfolioView();
  }
}

class _PortfolioView extends StatelessWidget {
  const _PortfolioView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppFeedback.alertToastSuccess(context, state.successMessage!);
          context.read<PortfolioCubit>().clearMessages();
        }
        if (state.errorMessage != null) {
          AppFeedback.alertToastError(context, state.errorMessage!);
          context.read<PortfolioCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state.status == PortfolioStatus.loading &&
            state.subscriptions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => context.read<PortfolioCubit>().loadPortfolio(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Mis fondos suscritos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.filteredSubscriptions.isEmpty)
                const SizedBox(
                  height: 300,
                  child: EmptyStateWidget(
                    icon: Icons.account_balance_outlined,
                    title: 'Sin resultados',
                    subtitle: 'No hay suscripciones que coincidan con la búsqueda.',
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BtgPaginatedTable<Subscription>(
                    items: state.filteredSubscriptions,
                    initialRowsPerPage: 5,
                    columns: [
                      BtgTableColumn<Subscription>(
                        label: 'Fondo',
                        flex: 2.2,
                        cellBuilder: (sub) => Text(sub.fundName),
                      ),
                      BtgTableColumn<Subscription>(
                        label: 'Monto suscrito',
                        flex: 1.4,
                        cellBuilder: (sub) => Text(
                          '\$ ${sub.amount.toStringAsFixed(0)}',
                        ),
                      ),
                      BtgTableColumn<Subscription>(
                        label: 'Fecha',
                        flex: 1.4,
                        cellBuilder: (sub) => Text(
                          '${sub.date.day.toString().padLeft(2, '0')}/'
                          '${sub.date.month.toString().padLeft(2, '0')}/'
                          '${sub.date.year}',
                        ),
                      ),
                      BtgTableColumn<Subscription>(
                        label: 'Acciones',
                        flex: 1.2,
                        cellBuilder: (sub) => Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _showCancelDialog(
                              context,
                              sub.fundId,
                              sub.fundName,
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancelar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    String fundId,
    String fundName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: Text(
          '¿Está seguro que desea cancelar su suscripción al fondo $fundName? '
          'El monto será devuelto a su saldo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<PortfolioCubit>()
                  .cancelSubscription(fundId, fundName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
