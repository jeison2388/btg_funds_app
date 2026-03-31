import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/errors/app_exception.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';
import 'package:btg_funds_app/infrastructure/mappers/subscription_mapper.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final HiveLocalDatasource _localDatasource;

  PortfolioRepositoryImpl(this._localDatasource);

  @override
  Future<double> getBalance() async {
    return _localDatasource.getBalance();
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final dtos = _localDatasource.getSubscriptions();
    return dtos.map(SubscriptionMapper.toModel).toList();
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
      SubscriptionMapper.toDto(subscription),
    );
    await _localDatasource.updateBalance(
      currentBalance - fund.minimumAmount,
    );
  }

  @override
  Future<void> cancel(String fundId) async {
    final existing = _localDatasource.getSubscriptionByFundId(fundId);
    if (existing == null) {
      throw const SubscriptionNotFoundException();
    }

    final currentBalance = _localDatasource.getBalance();
    await _localDatasource.removeSubscriptionByFundId(fundId);
    await _localDatasource.updateBalance(currentBalance + existing.amount);
  }
}
