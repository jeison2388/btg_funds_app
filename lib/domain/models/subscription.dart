import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';

class Subscription extends Equatable {
  final String fundId;
  final String fundName;
  final double amount;
  final DateTime date;
  final NotificationMethod notificationMethod;

  const Subscription({
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.date,
    required this.notificationMethod,
  });

  @override
  List<Object?> get props => [
        fundId,
        fundName,
        amount,
        date,
        notificationMethod,
      ];
}
