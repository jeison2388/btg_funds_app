import 'package:btg_funds_app/domain/models/transaction.dart';

abstract class TransactionRepository {
  Future<List<FundTransaction>> getAll();
  Future<void> add(FundTransaction transaction);
}
