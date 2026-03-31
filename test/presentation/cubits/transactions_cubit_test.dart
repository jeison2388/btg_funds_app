import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_cubit.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_state.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late TransactionsCubit cubit;

  final testTransactions = [
    FundTransaction(
      id: 'tx-001',
      type: TransactionType.subscription,
      fundId: '1',
      fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
      amount: 75000,
      date: DateTime(2025, 6, 15),
      notificationMethod: NotificationMethod.email,
    ),
    FundTransaction(
      id: 'tx-002',
      type: TransactionType.cancellation,
      fundId: '1',
      fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
      amount: 0,
      date: DateTime(2025, 6, 16),
    ),
  ];

  setUp(() {
    mockRepository = MockTransactionRepository();
    cubit = TransactionsCubit(mockRepository);
  });

  tearDown(() => cubit.close());

  group('TransactionsCubit', () {
    test('estado inicial es correcto', () {
      expect(cubit.state.status, TransactionsStatus.initial);
      expect(cubit.state.transactions, isEmpty);
    });

    test('loadTransactions emite [loading, loaded] con transacciones', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => testTransactions);
      final emitted = <TransactionsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadTransactions();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [
        const TransactionsState(status: TransactionsStatus.loading),
        TransactionsState(
          status: TransactionsStatus.loaded,
          transactions: testTransactions,
        ),
      ]);
      await sub.cancel();
    });

    test('loadTransactions emite [loading, error] cuando falla', () async {
      when(() => mockRepository.getAll()).thenThrow(Exception('DB error'));
      final emitted = <TransactionsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadTransactions();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted.first, const TransactionsState(status: TransactionsStatus.loading));
      expect(emitted.last.status, TransactionsStatus.error);
      expect(emitted.last.errorMessage, isNotNull);
      await sub.cancel();
    });
  });
}
