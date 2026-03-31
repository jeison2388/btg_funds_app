import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_state.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/widgets/category_filter.dart';
import 'package:btg_funds_app/presentation/widgets/empty_state_widget.dart';
import 'package:btg_funds_app/presentation/widgets/fund_card.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Fondos disponibles')),
      body: BlocBuilder<FundsCubit, FundsState>(
        builder: (context, fundsState) {
          if (fundsState.status == FundsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (fundsState.status == FundsStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(fundsState.errorMessage ?? 'Error desconocido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FundsCubit>().loadFunds(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              CategoryFilter(
                selectedCategory: fundsState.selectedCategory,
                onCategoryChanged: (cat) =>
                    context.read<FundsCubit>().filterByCategory(cat),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: fundsState.filteredFunds.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.search_off,
                        title: 'Sin resultados',
                        subtitle:
                            'No hay fondos para la categoría seleccionada.',
                      )
                    : BlocBuilder<PortfolioCubit, PortfolioState>(
                        builder: (context, portfolioState) {
                          final subscribedIds = portfolioState
                              .subscriptions
                              .map((s) => s.fundId)
                              .toSet();

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return _buildFundsList(
                                context,
                                fundsState.filteredFunds,
                                subscribedIds,
                                constraints,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFundsList(
    BuildContext context,
    List<Fund> funds,
    Set<String> subscribedIds,
    BoxConstraints constraints,
  ) {
    if (constraints.maxWidth > 600) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: funds.length,
        itemBuilder: (context, index) {
          final fund = funds[index];
          return FundCard(
            fund: fund,
            isSubscribed: subscribedIds.contains(fund.id),
            onSubscribe: () => _navigateToSubscribe(context, fund),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: funds.length,
      itemBuilder: (context, index) {
        final fund = funds[index];
        return FundCard(
          fund: fund,
          isSubscribed: subscribedIds.contains(fund.id),
          onSubscribe: () => _navigateToSubscribe(context, fund),
        );
      },
    );
  }

  Future<void> _navigateToSubscribe(
      BuildContext context, Fund fund) async {
    await context.router.push(SubscribeRoute(fund: fund));
    if (context.mounted) {
      context.read<PortfolioCubit>().loadPortfolio();
    }
  }
}
