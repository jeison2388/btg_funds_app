import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';

class Fund extends Equatable {
  final String id;
  final String name;
  final double minimumAmount;
  final FundCategory category;

  const Fund({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, minimumAmount, category];
}
