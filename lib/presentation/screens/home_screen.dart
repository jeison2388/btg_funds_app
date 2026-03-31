import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/core/utils/app_feedback.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_state.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/widgets/balance_header.dart';
import 'package:btg_funds_app/presentation/widgets/btg_paginated_table.dart';
import 'package:btg_funds_app/presentation/widgets/btg_tabbed_filters.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => Injector.resolve<FundsCubit>()..loadFunds(),
        ),
        BlocProvider(
          create: (_) => Injector.resolve<PortfolioCubit>()..loadPortfolio(),
        ),
        BlocProvider(
          create: (_) =>
              Injector.resolve<TransactionsCubit>()..loadTransactions(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        PortfolioRoute(),
        FundsRoute(),
        TransactionHistoryRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final isPortfolioTab = tabsRouter.activeIndex == 0;
        final isFundsTab = tabsRouter.activeIndex == 1;
        final isHistoryTab = tabsRouter.activeIndex == 2;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                BlocBuilder<PortfolioCubit, PortfolioState>(
                  builder: (context, state) {
                    return BalanceHeader(balance: state.balance);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: BlocBuilder<FundsCubit, FundsState>(
                    builder: (context, fundsState) {
                      return BtgTabbedFilters(
                        tabs: const [
                          'Mi Portafolio',
                          'Fondos',
                          'Historial',
                        ],
                        selectedTab: tabsRouter.activeIndex,
                        onTabChanged: (index) {
                          tabsRouter.setActiveIndex(index);
                          _reloadTab(context, index);
                        },
                        showSearch: isPortfolioTab || isFundsTab || isHistoryTab,
                        searchHintText: isPortfolioTab
                            ? 'Buscar suscripción por fondo'
                            : isFundsTab
                                ? 'Buscar fondo por nombre'
                                : 'Buscar en historial',
                        onSearch: (query) {
                          if (isPortfolioTab) {
                            context.read<PortfolioCubit>().filterByName(query);
                          } else if (isFundsTab) {
                            context.read<FundsCubit>().filterByName(query);
                          } else if (isHistoryTab) {
                            context.read<TransactionsCubit>().filterByName(query);
                          }
                        },
                        filters: isFundsTab
                            ? [
                                BtgFilterDropdownConfig<FundCategory>(
                                  label: 'Categoría',
                                  defaultOptionLabel: 'Todos',
                                  selectedValue: fundsState.selectedCategory,
                                  items: const {
                                    FundCategory.fpv: 'FPV',
                                    FundCategory.fic: 'FIC',
                                  },
                                  onChanged: (category) => context
                                      .read<FundsCubit>()
                                      .filterByCategory(category),
                                ),
                              ]
                            : const [],
                      );
                    },
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  void _reloadTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.read<PortfolioCubit>().loadPortfolio();
        break;
      case 1:
        context.read<PortfolioCubit>().loadPortfolio();
        break;
      case 2:
        context.read<TransactionsCubit>().loadTransactions();
        break;
    }
  }
}

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
