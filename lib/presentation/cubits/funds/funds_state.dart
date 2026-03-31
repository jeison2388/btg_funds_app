import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/models/fund.dart';

enum FundsStatus { initial, loading, loaded, error }

class FundsState extends Equatable {
  final FundsStatus status;
  final List<Fund> funds;
  final FundCategory? selectedCategory;
  final String? errorMessage;

  const FundsState({
    this.status = FundsStatus.initial,
    this.funds = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  List<Fund> get filteredFunds {
    if (selectedCategory == null) return funds;
    return funds.where((f) => f.category == selectedCategory).toList();
  }

  FundsState copyWith({
    FundsStatus? status,
    List<Fund>? funds,
    FundCategory? Function()? selectedCategory,
    String? Function()? errorMessage,
  }) {
    return FundsState(
      status: status ?? this.status,
      funds: funds ?? this.funds,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, funds, selectedCategory, errorMessage];
}
