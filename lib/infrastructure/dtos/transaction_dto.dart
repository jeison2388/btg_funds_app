import 'package:hive/hive.dart';

part 'transaction_dto.g.dart';

@HiveType(typeId: 1)
class TransactionDto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String fundId;

  @HiveField(3)
  final String fundName;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? notificationMethod;

  TransactionDto({
    required this.id,
    required this.type,
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.date,
    this.notificationMethod,
  });
}
