import 'package:equatable/equatable.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/models/fund.dart';

enum FundsStatus { initial, loading, loaded, error }

class FundsState extends Equatable {
  final FundsStatus status;
  final List<Fund> funds;
  final FundCategory? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const FundsState({
    this.status = FundsStatus.initial,
    this.funds = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  List<Fund> get filteredFunds {
    final query = searchQuery.trim().toLowerCase();
    return funds.where((fund) {
      final categoryMatch =
          selectedCategory == null || fund.category == selectedCategory;
      final queryMatch =
          query.isEmpty || fund.name.toLowerCase().contains(query);
      return categoryMatch && queryMatch;
    }).toList();
  }

  FundsState copyWith({
    FundsStatus? status,
    List<Fund>? funds,
    FundCategory? Function()? selectedCategory,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return FundsState(
      status: status ?? this.status,
      funds: funds ?? this.funds,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, funds, selectedCategory, searchQuery, errorMessage];
}
