import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/infrastructure/dtos/subscription_dto.dart';

abstract class SubscriptionMapper {
  static Subscription toModel(SubscriptionDto dto) {
    return Subscription(
      fundId: dto.fundId,
      fundName: dto.fundName,
      amount: dto.amount,
      date: dto.date,
      notificationMethod: NotificationMethod.values.firstWhere(
        (e) => e.name == dto.notificationMethod,
        orElse: () => NotificationMethod.email,
      ),
    );
  }

  static SubscriptionDto toDto(Subscription model) {
    return SubscriptionDto(
      fundId: model.fundId,
      fundName: model.fundName,
      amount: model.amount,
      date: model.date,
      notificationMethod: model.notificationMethod.name,
    );
  }
}
