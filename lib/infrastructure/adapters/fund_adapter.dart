import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/adapters/model_adapter.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/infrastructure/dtos/fund_dto.dart';

class FundAdapter extends ModelAdapter<Fund, FundDto> {
  const FundAdapter();

  @override
  Fund toModel(FundDto external) {
    return Fund(
      id: external.id,
      name: external.name,
      minimumAmount: external.minimumAmount,
      category: FundCategory.values.firstWhere(
        (e) => e.name == external.category,
        orElse: () => FundCategory.fpv,
      ),
    );
  }

  @override
  FundDto fromModel(Fund model) {
    return FundDto(
      id: model.id,
      name: model.name,
      minimumAmount: model.minimumAmount,
      category: model.category.name,
    );
  }
}
