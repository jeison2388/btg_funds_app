import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/presentation/funds/funds_state.dart';

class FundsCubit extends Cubit<FundsState> {
  final FundRepository _fundRepository;

  FundsCubit(this._fundRepository) : super(const FundsState());

  Future<void> loadFunds() async {
    emit(state.copyWith(status: FundsStatus.loading));
    try {
      final funds = await _fundRepository.getAll();
      emit(state.copyWith(
        status: FundsStatus.loaded,
        funds: funds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FundsStatus.error,
        errorMessage: () => 'Error al cargar los fondos: $e',
      ));
    }
  }

  void filterByCategory(FundCategory? category) {
    emit(state.copyWith(selectedCategory: () => category));
  }

  void filterByName(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
