import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/core/utils/app_feedback.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_state.dart';
import 'package:btg_funds_app/presentation/widgets/category_chip.dart';
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
      create: (_) =>
          Injector.resolve<PortfolioCubit>()..loadPortfolio(),
      child: BlocConsumer<PortfolioCubit, PortfolioState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppFeedback.alertToastSuccess(context, state.successMessage!);
            context.read<PortfolioCubit>().clearMessages();
            context.router.maybePop();
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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Suscribirse a fondo'),
            ),
            body: LoadingOverlay(
              isLoading: state.status == PortfolioStatus.loading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fund info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.fund.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  CategoryChip(
                                      category: widget.fund.category),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                icon: Icons.monetization_on_outlined,
                                label: 'Monto mínimo',
                                value: formatter
                                    .format(widget.fund.minimumAmount),
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.account_balance_wallet,
                                label: 'Su saldo actual',
                                value: formatter.format(state.balance),
                                valueColor: hasEnoughBalance
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Validation messages
                      if (!hasEnoughBalance) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppTheme.errorColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: AppTheme.errorColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No cuenta con saldo suficiente para '
                                  'vincularse a este fondo.',
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (isAlreadySubscribed) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ya se encuentra vinculado a este fondo.',
                                  style:
                                      TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Notification selector
                      if (hasEnoughBalance && !isAlreadySubscribed) ...[
                        NotificationSelector(
                          initialValue: _selectedMethod,
                          onChanged: (method) {
                            setState(() => _selectedMethod = method);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Debe seleccionar un método de notificación';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Subscribe button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _onSubscribe(context),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Confirmar suscripción'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
