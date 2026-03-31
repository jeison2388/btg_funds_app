import 'package:hive/hive.dart';

part 'subscription_dto.g.dart';

@HiveType(typeId: 0)
class SubscriptionDto extends HiveObject {
  @HiveField(0)
  final String fundId;

  @HiveField(1)
  final String fundName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String notificationMethod;

  SubscriptionDto({
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.date,
    required this.notificationMethod,
  });
}
