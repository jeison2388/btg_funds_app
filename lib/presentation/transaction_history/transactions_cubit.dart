import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsCubit(this._transactionRepository)
      : super(const TransactionsState());

  void _safeEmit(TransactionsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadTransactions() async {
    _safeEmit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final transactions = await _transactionRepository.getAll();
      _safeEmit(state.copyWith(
        status: TransactionsStatus.loaded,
        transactions: transactions,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: TransactionsStatus.error,
        errorMessage: () => 'Error al cargar el historial: $e',
      ));
    }
  }

  void filterByName(String query) {
    _safeEmit(state.copyWith(searchQuery: query));
  }
}
