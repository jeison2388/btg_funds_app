import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsCubit(this._transactionRepository)
      : super(const TransactionsState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final transactions = await _transactionRepository.getAll();
      emit(state.copyWith(
        status: TransactionsStatus.loaded,
        transactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.error,
        errorMessage: () => 'Error al cargar el historial: $e',
      ));
    }
  }

  void filterByName(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
