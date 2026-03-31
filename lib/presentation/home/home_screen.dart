import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';
import 'package:btg_funds_app/presentation/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/funds/funds_state.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/widgets/balance_header.dart';
import 'package:btg_funds_app/presentation/widgets/btg_tabbed_filters.dart';

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
