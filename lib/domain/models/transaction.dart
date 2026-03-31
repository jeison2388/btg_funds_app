import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';

class FundTransaction extends Equatable {
  final String id;
  final TransactionType type;
  final String fundId;
  final String fundName;
  final double amount;
  final DateTime date;
  final NotificationMethod? notificationMethod;

  const FundTransaction({
    required this.id,
    required this.type,
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.date,
    this.notificationMethod,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        fundId,
        fundName,
        amount,
        date,
        notificationMethod,
      ];
}
