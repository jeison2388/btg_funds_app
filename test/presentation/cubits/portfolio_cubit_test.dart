import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/errors/app_exception.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_state.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeFundTransaction extends Fake implements FundTransaction {}

class FakeFund extends Fake implements Fund {}

void main() {
  late MockPortfolioRepository mockPortfolioRepo;
  late MockTransactionRepository mockTransactionRepo;
  late PortfolioCubit cubit;

  const testFund = Fund(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
  );

  setUpAll(() {
    registerFallbackValue(FakeFundTransaction());
    registerFallbackValue(FakeFund());
    registerFallbackValue(NotificationMethod.email);
  });

  setUp(() {
    mockPortfolioRepo = MockPortfolioRepository();
    mockTransactionRepo = MockTransactionRepository();
    cubit = PortfolioCubit(mockPortfolioRepo, mockTransactionRepo);
  });

  tearDown(() => cubit.close());

  group('PortfolioCubit', () {
    test('estado inicial es correcto', () {
      expect(cubit.state.status, PortfolioStatus.initial);
      expect(cubit.state.balance, 0);
      expect(cubit.state.subscriptions, isEmpty);
    });

    test('loadPortfolio emite [loading, loaded] con datos correctos', () async {
      when(() => mockPortfolioRepo.getBalance()).thenAnswer((_) async => 500000);
      when(() => mockPortfolioRepo.getSubscriptions()).thenAnswer((_) async => []);
      final emitted = <PortfolioState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadPortfolio();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [
        const PortfolioState(status: PortfolioStatus.loading),
        const PortfolioState(
          status: PortfolioStatus.loaded,
          balance: 500000,
        ),
      ]);
      await sub.cancel();
    });

    test('subscribe emite error cuando saldo es insuficiente', () async {
      when(() => mockPortfolioRepo.subscribe(any(), any()))
          .thenThrow(const InsufficientBalanceException());
      when(() => mockPortfolioRepo.getBalance()).thenAnswer((_) async => 500000);
      when(() => mockPortfolioRepo.getSubscriptions()).thenAnswer((_) async => []);
      final emitted = <PortfolioState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.subscribe(testFund, NotificationMethod.email);
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 4);
      expect(emitted[0].status, PortfolioStatus.loading);
      expect(emitted[1].errorMessage, contains('saldo suficiente'));
      expect(emitted[2].status, PortfolioStatus.loading);
      expect(emitted[3].status, PortfolioStatus.loaded);
      await sub.cancel();
    });

    test('subscribe emite success cuando todo es correcto', () async {
      when(() => mockPortfolioRepo.subscribe(any(), any())).thenAnswer((_) async {});
      when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
      when(() => mockPortfolioRepo.getBalance()).thenAnswer((_) async => 425000);
      when(() => mockPortfolioRepo.getSubscriptions()).thenAnswer((_) async => []);
      final emitted = <PortfolioState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.subscribe(testFund, NotificationMethod.sms);
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted.first.status, PortfolioStatus.loading);
      expect(emitted.last.status, PortfolioStatus.loaded);
      expect(emitted.last.balance, 425000);
      expect(emitted.last.successMessage, isNotNull);
      verify(() => mockTransactionRepo.add(any())).called(1);
      await sub.cancel();
    });

    test('cancelSubscription emite success y actualiza saldo', () async {
      when(() => mockPortfolioRepo.cancel(any())).thenAnswer((_) async => 75000);
      when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
      when(() => mockPortfolioRepo.getBalance()).thenAnswer((_) async => 500000);
      when(() => mockPortfolioRepo.getSubscriptions()).thenAnswer((_) async => []);
      final emitted = <PortfolioState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.cancelSubscription('1', 'FPV_BTG_PACTUAL_RECAUDADORA');
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted.first.status, PortfolioStatus.loading);
      expect(emitted.last.status, PortfolioStatus.loaded);
      expect(emitted.last.balance, 500000);
      expect(emitted.last.successMessage, contains('cancelado'));
      await sub.cancel();
    });
  });
}
