import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';

enum TransactionsStatus { initial, loading, loaded, error }

class TransactionsState extends Equatable {
  final TransactionsStatus status;
  final List<FundTransaction> transactions;
  final String? errorMessage;

  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<FundTransaction>? transactions,
    String? Function()? errorMessage,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
