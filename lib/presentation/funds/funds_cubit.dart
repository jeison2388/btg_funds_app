import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/presentation/funds/funds_state.dart';

class FundsCubit extends Cubit<FundsState> {
  final FundRepository _fundRepository;

  FundsCubit(this._fundRepository) : super(const FundsState());

  void _safeEmit(FundsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadFunds() async {
    _safeEmit(state.copyWith(status: FundsStatus.loading));
    try {
      final funds = await _fundRepository.getAll();
      _safeEmit(state.copyWith(
        status: FundsStatus.loaded,
        funds: funds,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: FundsStatus.error,
        errorMessage: () => 'Error al cargar los fondos: $e',
      ));
    }
  }

  void filterByCategory(FundCategory? category) {
    _safeEmit(state.copyWith(selectedCategory: () => category));
  }

  void filterByName(String query) {
    _safeEmit(state.copyWith(searchQuery: query));
  }
}
