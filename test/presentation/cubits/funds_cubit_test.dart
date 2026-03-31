import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_state.dart';

class MockFundRepository extends Mock implements FundRepository {}

void main() {
  late MockFundRepository mockRepository;
  late FundsCubit cubit;

  final testFunds = [
    const Fund(
      id: '1',
      name: 'FPV_BTG_PACTUAL_RECAUDADORA',
      minimumAmount: 75000,
      category: FundCategory.fpv,
    ),
    const Fund(
      id: '3',
      name: 'DEUDAPRIVADA',
      minimumAmount: 50000,
      category: FundCategory.fic,
    ),
  ];

  setUp(() {
    mockRepository = MockFundRepository();
    cubit = FundsCubit(mockRepository);
  });

  tearDown(() => cubit.close());

  group('FundsCubit', () {
    test('estado inicial es correcto', () {
      expect(cubit.state, const FundsState());
      expect(cubit.state.status, FundsStatus.initial);
    });

    test('loadFunds emite [loading, loaded] cuando es exitoso', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => testFunds);
      final emitted = <FundsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadFunds();
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [
        const FundsState(status: FundsStatus.loading),
        FundsState(status: FundsStatus.loaded, funds: testFunds),
      ]);
      await sub.cancel();
    });

    test('loadFunds emite [loading, error] cuando falla', () async {
      when(() => mockRepository.getAll()).thenThrow(Exception('API error'));
      final emitted = <FundsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadFunds();
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted.first, const FundsState(status: FundsStatus.loading));
      expect(emitted.last.status, FundsStatus.error);
      expect(emitted.last.errorMessage, isNotNull);
      await sub.cancel();
    });

    test('filterByCategory filtra fondos correctamente', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => testFunds);
      await cubit.loadFunds();

      cubit.filterByCategory(FundCategory.fpv);

      expect(cubit.state.selectedCategory, FundCategory.fpv);
      expect(cubit.state.filteredFunds.length, 1);
      expect(cubit.state.filteredFunds.first.id, '1');
    });

    test('filterByCategory con null muestra todos los fondos', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => testFunds);
      await cubit.loadFunds();
      cubit.filterByCategory(FundCategory.fpv);

      cubit.filterByCategory(null);

      expect(cubit.state.selectedCategory, isNull);
      expect(cubit.state.filteredFunds.length, 2);
    });
  });
}
