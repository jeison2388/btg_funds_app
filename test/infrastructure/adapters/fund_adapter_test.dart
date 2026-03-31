import 'package:flutter_test/flutter_test.dart';
import 'package:btg_funds_app/core/enums/fund_category.dart';
import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/infrastructure/adapters/fund_adapter.dart';
import 'package:btg_funds_app/infrastructure/dtos/fund_dto.dart';

void main() {
  group('FundAdapter', () {
    const adapter = FundAdapter();

    test('toModel convierte DTO a dominio', () {
      const dto = FundDto(
        id: '1',
        name: 'FPV_TEST',
        minimumAmount: 75000,
        category: 'fpv',
      );
      final model = adapter.toModel(dto);
      expect(model.id, '1');
      expect(model.name, 'FPV_TEST');
      expect(model.minimumAmount, 75000);
      expect(model.category, FundCategory.fpv);
    });

    test('fromModel convierte dominio a DTO', () {
      const model = Fund(
        id: '2',
        name: 'FIC_TEST',
        minimumAmount: 50000,
        category: FundCategory.fic,
      );
      final dto = adapter.fromModel(model);
      expect(dto.id, '2');
      expect(dto.category, 'fic');
    });

    test('bidireccional conserva datos', () {
      const original = Fund(
        id: '3',
        name: 'X',
        minimumAmount: 100,
        category: FundCategory.fpv,
      );
      final restored = adapter.toModel(adapter.fromModel(original));
      expect(restored, original);
    });
  });
}
