import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/widgets/balance_header.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';
import 'package:btg_funds_app/presentation/widgets/subscription_card.dart';

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
    return AutoTabsScaffold(
      routes: const [
        PortfolioRoute(),
        FundsRoute(),
        TransactionHistoryRoute(),
      ],
      transitionBuilder: (context, child, animation) => child,
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: (index) {
            tabsRouter.setActiveIndex(index);
            _reloadTab(context, index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Mi Portafolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Fondos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Historial',
            ),
          ],
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
    final theme = Theme.of(context);

    return BlocConsumer<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          context.read<PortfolioCubit>().clearMessages();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
          context.read<PortfolioCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        if (state.status == PortfolioStatus.loading &&
            state.subscriptions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () =>
              context.read<PortfolioCubit>().loadPortfolio(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BalanceHeader(balance: state.balance),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Mis fondos suscritos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (state.subscriptions.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    icon: Icons.account_balance_outlined,
                    title: 'Sin suscripciones',
                    subtitle:
                        'Aún no te has suscrito a ningún fondo.\nExplora los fondos disponibles.',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sub = state.subscriptions[index];
                      return SubscriptionCard(
                        subscription: sub,
                        onCancel: () => _showCancelDialog(
                          context,
                          sub.fundId,
                          sub.fundName,
                        ),
                      );
                    },
                    childCount: state.subscriptions.length,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
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
