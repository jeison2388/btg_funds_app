import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/errors/app_exception.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/infrastructure/adapters/subscription_adapter.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final HiveLocalDatasource _localDatasource;
  final SubscriptionAdapter _subscriptionAdapter;

  PortfolioRepositoryImpl(
    this._localDatasource,
    this._subscriptionAdapter,
  );

  @override
  Future<double> getBalance() async {
    return _localDatasource.getBalance();
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final dtos = _localDatasource.getSubscriptions();
    return _subscriptionAdapter.toListModel(dtos);
  }

  @override
  Future<void> subscribe(Fund fund, NotificationMethod method) async {
    final currentBalance = _localDatasource.getBalance();

    if (currentBalance < fund.minimumAmount) {
      throw const InsufficientBalanceException();
    }

    final existing = _localDatasource.getSubscriptionByFundId(fund.id);
    if (existing != null) {
      throw const AlreadySubscribedException();
    }

    final subscription = Subscription(
      fundId: fund.id,
      fundName: fund.name,
      amount: fund.minimumAmount,
      date: DateTime.now(),
      notificationMethod: method,
    );

    await _localDatasource.addSubscription(
      _subscriptionAdapter.fromModel(subscription),
    );
    await _localDatasource.updateBalance(
      currentBalance - fund.minimumAmount,
    );
  }

  @override
  Future<double> cancel(String fundId) async {
    final existing = _localDatasource.getSubscriptionByFundId(fundId);
    if (existing == null) {
      throw const SubscriptionNotFoundException();
    }

    final refundAmount = existing.amount;
    final currentBalance = _localDatasource.getBalance();
    await _localDatasource.removeSubscriptionByFundId(fundId);
    await _localDatasource.updateBalance(currentBalance + refundAmount);
    return refundAmount;
  }
}
