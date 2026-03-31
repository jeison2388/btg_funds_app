import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/domain/adapters/model_adapter.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/infrastructure/dtos/subscription_dto.dart';

class SubscriptionAdapter extends ModelAdapter<Subscription, SubscriptionDto> {
  const SubscriptionAdapter();

  @override
  Subscription toModel(SubscriptionDto external) {
    return Subscription(
      fundId: external.fundId,
      fundName: external.fundName,
      amount: external.amount,
      date: external.date,
      notificationMethod: NotificationMethod.values.firstWhere(
        (e) => e.name == external.notificationMethod,
        orElse: () => NotificationMethod.email,
      ),
    );
  }

  @override
  SubscriptionDto fromModel(Subscription model) {
    return SubscriptionDto(
      fundId: model.fundId,
      fundName: model.fundName,
      amount: model.amount,
      date: model.date,
      notificationMethod: model.notificationMethod.name,
    );
  }
}
