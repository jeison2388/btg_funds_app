import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';

enum PortfolioStatus { initial, loading, loaded, error }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final double balance;
  final List<Subscription> subscriptions;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.balance = 0,
    this.subscriptions = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  List<Subscription> get filteredSubscriptions {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return subscriptions;
    return subscriptions
        .where((sub) => sub.fundName.toLowerCase().contains(query))
        .toList();
  }

  PortfolioState copyWith({
    PortfolioStatus? status,
    double? balance,
    List<Subscription>? subscriptions,
    String? searchQuery,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      subscriptions: subscriptions ?? this.subscriptions,
      searchQuery: searchQuery ?? this.searchQuery,
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
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
