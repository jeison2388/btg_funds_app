import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';
import 'package:btg_funds_app/infrastructure/mappers/transaction_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final HiveLocalDatasource _localDatasource;

  TransactionRepositoryImpl(this._localDatasource);

  @override
  Future<List<FundTransaction>> getAll() async {
    final dtos = _localDatasource.getTransactions();
    final transactions = dtos.map(TransactionMapper.toModel).toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<void> add(FundTransaction transaction) async {
    await _localDatasource.addTransaction(
      TransactionMapper.toDto(transaction),
    );
  }
}
