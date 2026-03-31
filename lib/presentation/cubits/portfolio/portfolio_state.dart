import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';

enum PortfolioStatus { initial, loading, loaded, error }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final double balance;
  final List<Subscription> subscriptions;
  final String? errorMessage;
  final String? successMessage;

  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.balance = 0,
    this.subscriptions = const [],
    this.errorMessage,
    this.successMessage,
  });

  PortfolioState copyWith({
    PortfolioStatus? status,
    double? balance,
    List<Subscription>? subscriptions,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        subscriptions,
        errorMessage,
        successMessage,
      ];
}
