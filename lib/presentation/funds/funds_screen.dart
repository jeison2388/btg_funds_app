import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/presentation/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/funds/funds_state.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/widgets/btg_paginated_table.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';

@RoutePage()
class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FundsView();
  }
}

class _FundsView extends StatelessWidget {
  const _FundsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );

    return BlocBuilder<FundsCubit, FundsState>(
      builder: (context, fundsState) {
        if (fundsState.status == FundsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fundsState.status == FundsStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(fundsState.errorMessage ?? 'Error desconocido'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<FundsCubit>().loadFunds(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<PortfolioCubit, PortfolioState>(
          builder: (context, portfolioState) {
            final subscribedIds = portfolioState.subscriptions.map((s) => s.fundId).toSet();

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<FundsCubit>().loadFunds();
                if (context.mounted) {
                  await context.read<PortfolioCubit>().loadPortfolio();
                }
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  if (fundsState.filteredFunds.isEmpty)
                    const SizedBox(
                      height: 320,
                      child: EmptyStateWidget(
                        icon: Icons.search_off,
                        title: 'Sin resultados',
                        subtitle: 'No hay fondos para la categoría seleccionada.',
                      ),
                    )
                  else
                    BtgPaginatedTable<Fund>(
                      items: fundsState.filteredFunds,
                      columns: [
                        BtgTableColumn<Fund>(
                          label: 'Nombre',
                          flex: 2.4,
                          cellBuilder: (fund) => Text(fund.name),
                        ),
                        BtgTableColumn<Fund>(
                          label: 'Categoría',
                          flex: 1.2,
                          cellBuilder: (fund) => Text(fund.category.label),
                        ),
                        BtgTableColumn<Fund>(
                          label: 'Mínimo',
                          flex: 1.3,
                          cellBuilder: (fund) => Text(
                            currencyFormatter.format(fund.minimumAmount),
                          ),
                        ),
                        BtgTableColumn<Fund>(
                          label: 'Estado',
                          flex: 1.2,
                          cellBuilder: (fund) => Text(
                            subscribedIds.contains(fund.id)
                                ? 'Suscrito'
                                : 'Disponible',
                          ),
                        ),
                        BtgTableColumn<Fund>(
                          label: 'Acción',
                          flex: 1.4,
                          cellBuilder: (fund) => Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: subscribedIds.contains(fund.id)
                                  ? null
                                  : () => _navigateToSubscribe(context, fund),
                              child: Text(
                                subscribedIds.contains(fund.id)
                                    ? 'Suscrito'
                                    : 'Suscribirme',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToSubscribe(BuildContext context, Fund fund) {
    context.router.push(SubscribeRoute(fund: fund)).then((_) {
      if (context.mounted) {
        context.read<PortfolioCubit>().loadPortfolio();
      }
    }).catchError((_) {});
  }
}
