import 'package:hive_flutter/hive_flutter.dart';
import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/infrastructure/dtos/subscription_dto.dart';
import 'package:btg_funds_app/infrastructure/dtos/transaction_dto.dart';

class HiveLocalDatasource {
  static const String _balanceBoxName = 'portfolio';
  static const String _subscriptionsBoxName = 'subscriptions';
  static const String _transactionsBoxName = 'transactions';
  static const String _balanceKey = 'balance';

  late Box<double> _balanceBox;
  late Box<SubscriptionDto> _subscriptionsBox;
  late Box<TransactionDto> _transactionsBox;

  Future<void> init() async {
    try {
      _balanceBox = await Hive.openBox<double>(_balanceBoxName);
      _subscriptionsBox =
          await Hive.openBox<SubscriptionDto>(_subscriptionsBoxName);
      _transactionsBox =
          await Hive.openBox<TransactionDto>(_transactionsBoxName);
    } catch (_) {
      // Recupera el estado local cuando cambia el formato de serializacion
      // entre ejecuciones (comun en desarrollo web/hot restart).
      await Hive.deleteBoxFromDisk(_balanceBoxName);
      await Hive.deleteBoxFromDisk(_subscriptionsBoxName);
      await Hive.deleteBoxFromDisk(_transactionsBoxName);

      _balanceBox = await Hive.openBox<double>(_balanceBoxName);
      _subscriptionsBox =
          await Hive.openBox<SubscriptionDto>(_subscriptionsBoxName);
      _transactionsBox =
          await Hive.openBox<TransactionDto>(_transactionsBoxName);
    }

    if (!_balanceBox.containsKey(_balanceKey)) {
      await _balanceBox.put(_balanceKey, AppConstants.initialBalance);
    }
  }

  // Balance
  double getBalance() {
    return _balanceBox.get(_balanceKey, defaultValue: AppConstants.initialBalance)!;
  }

  Future<void> updateBalance(double balance) async {
    await _balanceBox.put(_balanceKey, balance);
  }

  // Subscriptions
  List<SubscriptionDto> getSubscriptions() {
    return _subscriptionsBox.values.toList();
  }

  SubscriptionDto? getSubscriptionByFundId(String fundId) {
    try {
      return _subscriptionsBox.values.firstWhere(
        (s) => s.fundId == fundId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addSubscription(SubscriptionDto subscription) async {
    await _subscriptionsBox.add(subscription);
  }

  Future<void> removeSubscriptionByFundId(String fundId) async {
    final key = _subscriptionsBox.keys.firstWhere(
      (k) => _subscriptionsBox.get(k)?.fundId == fundId,
    );
    await _subscriptionsBox.delete(key);
  }

  // Transactions
  List<TransactionDto> getTransactions() {
    return _transactionsBox.values.toList();
  }

  Future<void> addTransaction(TransactionDto transaction) async {
    await _transactionsBox.add(transaction);
  }

  /// Limpia toda la data (para testing).
  Future<void> clearAll() async {
    await _balanceBox.clear();
    await _subscriptionsBox.clear();
    await _transactionsBox.clear();
  }
}
