import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/core/utils/app_feedback.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/widgets/loading_overlay.dart';
import 'package:btg_funds_app/presentation/widgets/notification_selector.dart';

@RoutePage()
class SubscribeScreen extends StatefulWidget {
  final Fund fund;

  const SubscribeScreen({super.key, required this.fund});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final _formKey = GlobalKey<FormState>();
  NotificationMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: 'COP',
      decimalDigits: 0,
    );

    return BlocProvider(
      create: (_) => Injector.resolve<PortfolioCubit>()..loadPortfolio(),
      child: BlocConsumer<PortfolioCubit, PortfolioState>(
        listenWhen: (previous, current) {
          return previous.successMessage != current.successMessage ||
              previous.errorMessage != current.errorMessage;
        },
        listener: (context, state) {
          if (state.successMessage != null) {
            AppFeedback.alertToastSuccess(context, state.successMessage!);
            context.read<PortfolioCubit>().clearMessages();
            if (context.mounted) {
              context.router.maybePop();
            }
          }
          if (state.errorMessage != null) {
            AppFeedback.alertToastError(context, state.errorMessage!);
            context.read<PortfolioCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          final hasEnoughBalance =
              state.balance >= widget.fund.minimumAmount;
          final isAlreadySubscribed = state.subscriptions
              .any((s) => s.fundId == widget.fund.id);
          final canSubscribe = hasEnoughBalance && !isAlreadySubscribed;

          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              title: const Text('Suscribirse al fondo'),
            ),
            body: LoadingOverlay(
              isLoading: state.status == PortfolioStatus.loading,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FundSummaryCard(
                              fund: widget.fund,
                              balance: state.balance,
                              formatter: formatter,
                              hasEnoughBalance: hasEnoughBalance,
                            ),
                            const SizedBox(height: 24),
                            if (!hasEnoughBalance)
                              _AlertBanner(
                                icon: Icons.account_balance_wallet_outlined,
                                message:
                                    'No cuenta con saldo suficiente para suscribirse '
                                    'a este fondo. El monto mínimo es '
                                    '${formatter.format(widget.fund.minimumAmount)}.',
                                color: theme.colorScheme.error,
                                background: theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.45),
                              ),
                            if (isAlreadySubscribed) ...[
                              const SizedBox(height: 16),
                              _AlertBanner(
                                icon: Icons.check_circle_outline,
                                message:
                                    'Ya está suscrito a este fondo. Puede gestionarlo '
                                    'desde Mi portafolio.',
                                color: theme.colorScheme.tertiary,
                                background: theme.colorScheme.tertiaryContainer
                                    .withValues(alpha: 0.5),
                              ),
                            ],
                            if (canSubscribe) ...[
                              const SizedBox(height: 8),
                              NotificationSelector(
                                subtitle:
                                    'Le enviaremos la confirmación por el canal que elija.',
                                initialValue: _selectedMethod,
                                onChanged: (method) {
                                  setState(() => _selectedMethod = method);
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Seleccione email o SMS';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            SizedBox(height: canSubscribe ? 100 : 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (canSubscribe)
                    _SubscribeActionBar(
                      onConfirm: () => _onSubscribe(context),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSubscribe(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<PortfolioCubit>()
          .subscribe(widget.fund, _selectedMethod!);
    }
  }
}

class _FundSummaryCard extends StatelessWidget {
  final Fund fund;
  final double balance;
  final NumberFormat formatter;
  final bool hasEnoughBalance;

  const _FundSummaryCard({
    required this.fund,
    required this.balance,
    required this.formatter,
    required this.hasEnoughBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      elevation: 2,
      shadowColor: primary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.savings_outlined,
                      color: theme.colorScheme.onPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fund.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              fund.category.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatTile(
                    icon: Icons.payments_outlined,
                    label: 'Monto mínimo de entrada',
                    value: formatter.format(fund.minimumAmount),
                    valueColor: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 14),
                  _StatTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Su saldo disponible',
                    value: formatter.format(balance),
                    valueColor: hasEnoughBalance
                        ? AppTheme.successColor
                        : theme.colorScheme.error,
                    emphasize: true,
                  ),
                  if (hasEnoughBalance) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (balance - fund.minimumAmount) / balance.clamp(1, double.infinity),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: AppTheme.successColor.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tras suscribirse le quedará aprox. '
                      '${formatter.format(balance - fund.minimumAmount)} disponibles.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: (emphasize
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleSmall)
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final Color background;

  const _AlertBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeActionBar extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SubscribeActionBar({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 12,
      shadowColor: Colors.black26,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Revise el método de notificación y confirme.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.verified_outlined, size: 22),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Confirmar suscripción'),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
