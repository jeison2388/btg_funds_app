import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/models/fund.dart';

abstract class AppConstants {
  static const double initialBalance = 500000;

  static const String currencySymbol = 'COP';

  static const List<Fund> availableFunds = [
    Fund(
      id: '1',
      name: 'FPV_BTG_PACTUAL_RECAUDADORA',
      minimumAmount: 75000,
      category: FundCategory.fpv,
    ),
    Fund(
      id: '2',
      name: 'FPV_BTG_PACTUAL_ECOPETROL',
      minimumAmount: 125000,
      category: FundCategory.fpv,
    ),
    Fund(
      id: '3',
      name: 'DEUDAPRIVADA',
      minimumAmount: 50000,
      category: FundCategory.fic,
    ),
    Fund(
      id: '4',
      name: 'FDO-ACCIONES',
      minimumAmount: 250000,
      category: FundCategory.fic,
    ),
    Fund(
      id: '5',
      name: 'FPV_BTG_PACTUAL_DINAMICA',
      minimumAmount: 100000,
      category: FundCategory.fpv,
    ),
  ];
}
