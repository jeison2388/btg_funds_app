import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/adapters/model_adapter.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/infrastructure/dtos/transaction_dto.dart';

class TransactionAdapter extends ModelAdapter<FundTransaction, TransactionDto> {
  const TransactionAdapter();

  @override
  FundTransaction toModel(TransactionDto external) {
    return FundTransaction(
      id: external.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == external.type,
        orElse: () => TransactionType.subscription,
      ),
      fundId: external.fundId,
      fundName: external.fundName,
      amount: external.amount,
      date: external.date,
      notificationMethod: external.notificationMethod != null
          ? NotificationMethod.values.firstWhere(
              (e) => e.name == external.notificationMethod,
              orElse: () => NotificationMethod.email,
            )
          : null,
    );
  }

  @override
  TransactionDto fromModel(FundTransaction model) {
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
