import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';

abstract class PortfolioRepository {
  Future<double> getBalance();
  Future<List<Subscription>> getSubscriptions();
  Future<void> subscribe(Fund fund, NotificationMethod method);
  /// Devuelve el monto reembolsado al cancelar (para historial / trazabilidad).
  Future<double> cancel(String fundId);
}
