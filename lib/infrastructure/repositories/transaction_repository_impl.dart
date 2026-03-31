import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/infrastructure/adapters/transaction_adapter.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final HiveLocalDatasource _localDatasource;
  final TransactionAdapter _transactionAdapter;

  TransactionRepositoryImpl(
    this._localDatasource,
    this._transactionAdapter,
  );

  @override
  Future<List<FundTransaction>> getAll() async {
    final dtos = _localDatasource.getTransactions();
    final transactions = _transactionAdapter.toListModel(dtos);
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<void> add(FundTransaction transaction) async {
    await _localDatasource.addTransaction(
      _transactionAdapter.fromModel(transaction),
    );
  }
}
