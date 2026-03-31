import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';

enum TransactionsStatus { initial, loading, loaded, error }

class TransactionsState extends Equatable {
  final TransactionsStatus status;
  final List<FundTransaction> transactions;
  final String searchQuery;
  final String? errorMessage;

  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  List<FundTransaction> get filteredTransactions {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return transactions;
    return transactions.where((tx) {
      final fundMatch = tx.fundName.toLowerCase().contains(query);
      final typeMatch = tx.type.label.toLowerCase().contains(query);
      return fundMatch || typeMatch;
    }).toList();
  }

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<FundTransaction>? transactions,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, searchQuery, errorMessage];
}
