import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/infrastructure/dtos/transaction_dto.dart';

abstract class TransactionMapper {
  static FundTransaction toModel(TransactionDto dto) {
    return FundTransaction(
      id: dto.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == dto.type,
        orElse: () => TransactionType.subscription,
      ),
      fundId: dto.fundId,
      fundName: dto.fundName,
      amount: dto.amount,
      date: dto.date,
      notificationMethod: dto.notificationMethod != null
          ? NotificationMethod.values.firstWhere(
              (e) => e.name == dto.notificationMethod,
              orElse: () => NotificationMethod.email,
            )
          : null,
    );
  }

  static TransactionDto toDto(FundTransaction model) {
    return TransactionDto(
      id: model.id,
      type: model.type.name,
      fundId: model.fundId,
      fundName: model.fundName,
      amount: model.amount,
      date: model.date,
      notificationMethod: model.notificationMethod?.name,
    );
  }
}
