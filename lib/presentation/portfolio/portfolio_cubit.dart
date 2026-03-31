import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/core/errors/app_exception.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository _portfolioRepository;
  final TransactionRepository _transactionRepository;

  PortfolioCubit(
    this._portfolioRepository,
    this._transactionRepository,
  ) : super(const PortfolioState());

  Future<void> loadPortfolio() async {
    emit(state.copyWith(status: PortfolioStatus.loading));
    try {
      final balance = await _portfolioRepository.getBalance();
      final subscriptions = await _portfolioRepository.getSubscriptions();
      emit(state.copyWith(
        status: PortfolioStatus.loaded,
        balance: balance,
        subscriptions: subscriptions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PortfolioStatus.error,
        errorMessage: () => 'Error al cargar el portafolio: $e',
      ));
    }
  }

  Future<void> subscribe(Fund fund, NotificationMethod method) async {
    emit(state.copyWith(
      status: PortfolioStatus.loading,
      errorMessage: () => null,
      successMessage: () => null,
    ));
    try {
      await _portfolioRepository.subscribe(fund, method);

      final transaction = FundTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.subscription,
        fundId: fund.id,
        fundName: fund.name,
        amount: fund.minimumAmount,
        date: DateTime.now(),
        notificationMethod: method,
      );
      await _transactionRepository.add(transaction);

      final balance = await _portfolioRepository.getBalance();
      final subscriptions = await _portfolioRepository.getSubscriptions();

      emit(state.copyWith(
        status: PortfolioStatus.loaded,
        balance: balance,
        subscriptions: subscriptions,
        successMessage: () =>
            'Se ha suscrito exitosamente a ${fund.name}. '
            'Notificación enviada por ${method.label}.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: PortfolioStatus.loaded,
        errorMessage: () => e.message,
      ));
      await loadPortfolio();
    } catch (e) {
      emit(state.copyWith(
        status: PortfolioStatus.error,
        errorMessage: () => 'Error inesperado al suscribirse: $e',
      ));
    }
  }

  Future<void> cancelSubscription(String fundId, String fundName) async {
    emit(state.copyWith(
      status: PortfolioStatus.loading,
      errorMessage: () => null,
      successMessage: () => null,
    ));
    try {
      final refundAmount = await _portfolioRepository.cancel(fundId);

      final transaction = FundTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.cancellation,
        fundId: fundId,
        fundName: fundName,
        amount: refundAmount,
        date: DateTime.now(),
      );
      await _transactionRepository.add(transaction);

      final balance = await _portfolioRepository.getBalance();
      final subscriptions = await _portfolioRepository.getSubscriptions();

      emit(state.copyWith(
        status: PortfolioStatus.loaded,
        balance: balance,
        subscriptions: subscriptions,
        successMessage: () =>
            'Se ha cancelado la suscripción a $fundName exitosamente.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: PortfolioStatus.loaded,
        errorMessage: () => e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PortfolioStatus.error,
        errorMessage: () => 'Error inesperado al cancelar: $e',
      ));
    }
  }

  void clearMessages() {
    emit(state.copyWith(
      errorMessage: () => null,
      successMessage: () => null,
    ));
  }

  void filterByName(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
